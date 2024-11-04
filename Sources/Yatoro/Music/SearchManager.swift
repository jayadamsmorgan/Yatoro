import Foundation
import Logging
import MusicKit

public struct SearchResult {

    public let timestamp: Date

    public let searchType: SearchType
    public let itemType: MusicItemType

    public let searchPhrase: String?

    public let result: any AnyMusicItemCollection

}

public protocol AnyMusicItemCollection: Collection {
    func item(at index: Int) -> Element?
}

extension MusicItemCollection: AnyMusicItemCollection where Element: MusicItem {
    public func item(at index: Int) -> Element? {
        if (0..<self.count).contains(index) {
            return self[index]
        }
        return nil
    }
}

public enum SearchType: Hashable, CaseIterable, Sendable {
    case recentlyPlayed
    case recommended
    case catalogSearch
    case librarySearch
}

public class SearchManager: @unchecked Sendable {

    public static let shared: SearchManager = .init()

    public var lastSearchResult: SearchResult?

    private init() {}

    public func newSearch(for phrase: String? = nil, itemType: MusicItemType, in searchType: SearchType) async {
        var result: (any AnyMusicItemCollection)?

        switch searchType {

        case .recentlyPlayed:
            result = await getRecentlyPlayed() as MusicItemCollection<RecentlyPlayedMusicItem>?

        case .recommended:
            result = await getUserRecommendedBatch()

        case .catalogSearch:
            guard let phrase else { return }
            switch itemType {
            case .song:
                result = await searchCatalogBatch(for: phrase) as MusicItemCollection<Song>?
            case .album:
                result = await searchCatalogBatch(for: phrase) as MusicItemCollection<Album>?
            case .artist:
                result = await searchCatalogBatch(for: phrase) as MusicItemCollection<Artist>?
            case .playlist:
                result = await searchCatalogBatch(for: phrase) as MusicItemCollection<Playlist>?
            case .station:
                result = await searchCatalogBatch(for: phrase) as MusicItemCollection<Station>?
            }

        case .librarySearch:
            guard let phrase else { return }
            switch itemType {
            case .song:
                result = await searchUserLibraryBatch(for: phrase) as MusicItemCollection<Song>?
            case .album:
                result = await searchUserLibraryBatch(for: phrase) as MusicItemCollection<Album>?
            case .artist:
                result = await searchUserLibraryBatch(for: phrase) as MusicItemCollection<Artist>?
            case .playlist:
                result = await searchUserLibraryBatch(for: phrase) as MusicItemCollection<Playlist>?
            case .station: break  // Should be handled in commands since station is not MusicLibraryRequestable
            }

        }
        guard let result else {
            await logger?.debug("Search Manager: Search result is nil")
            return
        }

        let searchResult: SearchResult = .init(
            timestamp: Date.now,
            searchType: searchType,
            itemType: itemType,
            searchPhrase: phrase,
            result: result
        )
        lastSearchResult = searchResult
    }

}

// Requesting
public extension SearchManager {

    func getRecentlyPlayed<T>(
        limit: Int = 10
    ) async
        -> MusicItemCollection<T>?
    where T: Decodable, T: MusicRecentlyPlayedRequestable {
        await logger?.trace(
            "Get recently played for \(T.self): Requesting with limit \(limit)..."
        )
        var request = MusicRecentlyPlayedRequest<T>()
        request.limit = limit
        do {
            let response = try await request.response()
            await logger?.debug("Recently played response success: \(response)")
            return response.items
        } catch {
            await logger?.error(
                "Failed to make recently played request: \(error.localizedDescription)"
            )
            return nil
        }
    }

    func getRecentlyPlayedContainer(
        limit: Int = 10
    ) async
        -> MusicItemCollection<RecentlyPlayedMusicItem>?
    {
        await logger?.trace(
            "Get recently played container: Requesting with limit \(limit)..."
        )
        var request = MusicRecentlyPlayedContainerRequest()
        request.limit = limit
        do {
            let response = try await request.response()
            await logger?.debug(
                "Recently played container response success: \(response)"
            )
            return response.items
        } catch {
            await logger?.error(
                "Failed to make recently played container request: \(error.localizedDescription)"
            )
            return nil
        }
    }

    func getUserRecommendedBatch(
        limit: Int = 10
    ) async
        -> MusicItemCollection<MusicPersonalRecommendation>?
    {
        await logger?.trace(
            "Get user recommended batch: Requesting with limit \(limit)..."
        )
        var request = MusicPersonalRecommendationsRequest()
        request.limit = limit
        do {
            let response = try await request.response()
            await logger?.debug("Get user recommended batch: success: \(response)")
            return response.recommendations
        } catch {
            await logger?.error(
                "Failed to get user recommended batch: \(error.localizedDescription)"
            )
            return nil
        }
    }

    func getUserLibraryBatch<T>(
        limit: Int = 10,
        onlyOfflineContent: Bool = false
    ) async
        -> MusicItemCollection<T>?
    where T: MusicLibraryRequestable {
        await logger?.trace(
            "Get user library batch for \(T.self): Requesting with limit: \(limit), onlyOfflineContent: \(onlyOfflineContent)..."
        )
        var request = MusicLibraryRequest<T>()
        request.limit = limit
        request.includeOnlyDownloadedContent = onlyOfflineContent
        do {
            let response = try await request.response()
            await logger?.debug("Get user library batch: success: \(response)")
            return response.items
        } catch {
            await logger?.error(
                "Failed to make user library song request: \(error.localizedDescription)"
            )
            return nil
        }
    }

    func searchCatalogBatch<T>(
        for term: String,
        limit: Int = 10
    ) async
        -> MusicItemCollection<T>?
    where T: MusicCatalogSearchable {
        await logger?.trace(
            "Search catalog batch for \(T.self): Requesting with term \(term), limit \(limit)..."
        )
        var request = MusicCatalogSearchRequest(term: term, types: [T.self])
        if T.self == CatalogTopResult.self {
            await logger?.trace(
                "Search catalog batch for \(T.self): Including top results."
            )
            request.includeTopResults = true
        }
        request.limit = limit
        do {
            let response = try await request.response()
            await logger?.trace(
                "Search catalog batch for \(T.self): Response success \(response)"
            )
            var collection: MusicItemCollection<T>?
            switch T.self {
            case is Album.Type:
                collection = response.albums as? MusicItemCollection<T>
            case is Song.Type:
                collection = response.songs as? MusicItemCollection<T>
            case is Artist.Type:
                collection = response.artists as? MusicItemCollection<T>
            case is Curator.Type:
                collection = response.curators as? MusicItemCollection<T>
            case is Station.Type:
                collection = response.stations as? MusicItemCollection<T>
            case is Playlist.Type:
                collection = response.playlists as? MusicItemCollection<T>
            case is RadioShow.Type:
                collection = response.radioShows as? MusicItemCollection<T>
            case is CatalogTopResult.Type:
                collection = response.topResults as? MusicItemCollection<T>
            case is RecordLabel.Type:
                collection = response.recordLabels as? MusicItemCollection<T>
            case is MusicVideo.Type:
                collection = response.musicVideos as? MusicItemCollection<T>
            default:
                await logger?.error(
                    "Failed to search catalog batch: Type \(T.self) is not supported."
                )
            }
            guard let collection else {
                await logger?.error(
                    "Failed to search catalog batch: Unable to transform \(T.self) as \(T.self)"
                )
                return nil
            }
            await logger?.debug(
                "Search catalog batch for \(T.self): Success: \(collection)"
            )
            return collection
        } catch {
            await logger?.error(
                "Failed to search catalog batch for \(T.self): \(error.localizedDescription)"
            )
            return nil
        }
    }

    func searchUserLibraryBatch<T>(
        for term: String,
        limit: Int = 10
    ) async
        -> MusicItemCollection<T>?
    where T: MusicLibrarySearchable {
        await logger?.trace(
            "Search user library batch for \(T.self): Requesting with term \(term), limit \(limit)..."
        )
        var request = MusicLibrarySearchRequest(term: term, types: [T.self])
        if T.self == LibraryTopResult.self {
            await logger?.trace(
                "Search user library batch for \(T.self): Including top results."
            )
            request.includeTopResults = true
        }
        request.limit = limit
        do {
            let response = try await request.response()
            var collection: MusicItemCollection<T>?
            switch T.self {
            case is Song.Type:
                collection = response.songs as? MusicItemCollection<T>
            case is LibraryTopResult.Type:
                collection = response.topResults as? MusicItemCollection<T>
            case is Playlist.Type:
                collection = response.playlists as? MusicItemCollection<T>
            case is Album.Type:
                collection = response.albums as? MusicItemCollection<T>
            case is Artist.Type:
                collection = response.artists as? MusicItemCollection<T>
            case is MusicVideo.Type:
                collection = response.musicVideos as? MusicItemCollection<T>
            default:
                await logger?.error(
                    "Search user library failed: Unsupported type \(T.self)."
                )
                return nil
            }
            guard let collection else {
                await logger?.error(
                    "Search user library failed: Unable to transform \(T.self) type as \(T.self) type."
                )
                return nil
            }
            await logger?.debug(
                "Searching user library for \(T.self): success: \(collection)"
            )
            return collection
        } catch {
            await logger?.error(
                "Failed to search user library: Request error: \(error.localizedDescription)"
            )
            return nil
        }
    }

    func getAllCatalogCharts(
        limit: Int = 10
    ) async
        -> MusicCatalogChartsResponse?
    {
        await logger?.trace("Get all catalog charts: Requesting...")
        var request = MusicCatalogChartsRequest(types: [
            Song.self, Playlist.self, Album.self, MusicVideo.self,
        ])
        request.limit = limit
        do {
            let response = try await request.response()
            await logger?.trace("Get all catalog charts: success: \(response)")
            return response
        } catch {
            await logger?.error(
                "Failed to get all catalog charts: \(error.localizedDescription)"
            )
            return nil
        }
    }

    func getSpecificCatalogCharts<T>(
        limit: Int = 10
    ) async
        -> [MusicCatalogChart<T>]? where T: MusicCatalogChartRequestable
    {
        await logger?.trace("Get catalog charts for type \(T.self): Requesting...")
        var request = MusicCatalogChartsRequest(types: [T.self])
        request.limit = limit
        do {
            let response = try await request.response()
            var result: [MusicCatalogChart<T>]?
            switch T.self {
            case is Song.Type:
                result = response.songCharts as? [MusicCatalogChart<T>]
            case is Playlist.Type:
                result = response.playlistCharts as? [MusicCatalogChart<T>]
            case is Album.Type:
                result = response.albumCharts as? [MusicCatalogChart<T>]
            case is MusicVideo.Type:
                result = response.musicVideoCharts as? [MusicCatalogChart<T>]
            default:
                await logger?.error(
                    "Failed to get catalog charts for type \(T.self): Unsupported type."
                )
                return nil
            }
            guard let result else {
                await logger?.error(
                    "Failed to get catalog charts: Unable to transform \(T.self) as \(T.self)."
                )
                return nil
            }
            return result
        } catch {
            await logger?.error(
                "Failed to get catalog charts for type \(T.self): \(error.localizedDescription)"
            )
            return nil
        }
    }

    func nextMusicItemsBatch<T>(
        for previousBatch: MusicItemCollection<T>,
        limit: Int = 10
    ) async
        -> MusicItemCollection<T>?
    {
        guard previousBatch.hasNextBatch else {
            await logger?.trace(
                "Previous batch does not have next batch."
            )
            return nil
        }
        do {
            let response = try await previousBatch.nextBatch(limit: limit)
            guard let response else {
                await logger?.debug("Next batch is nil, should not happen.")
                return nil
            }
            await logger?.trace("Next batch success: \(response)")
            return response
        } catch {
            await logger?.error(
                "Failed to load next batch for previous batch \(previousBatch): \(error.localizedDescription)"
            )
            return nil
        }
    }

    func getUserLibrarySectioned<T, V>(
        for term: String? = nil,
        limit: Int = 10,
        onlyOfflineContent: Bool = false
    ) async
        -> MusicLibrarySectionedResponse<T, V>?
    where T: MusicLibrarySectionRequestable, V: MusicLibraryRequestable {
        await logger?.trace(
            "Get user library sectioned for section \(T.self) items \(V.self):"
                + " Requesting with term \(term ?? "'nil'"), limit \(limit), onlyOfflineContent: \(onlyOfflineContent)"
        )
        var request = MusicLibrarySectionedRequest<T, V>()
        request.limit = limit
        if let term {
            request.filterItems(text: term)
        }
        request.includeOnlyDownloadedContent = onlyOfflineContent
        // Items here could also be filtered by more complicated filters and sorted, probably not needed for now
        do {
            let response = try await request.response()
            await logger?.debug(
                "Get user library sectioned for section \(T.self) items \(V.self): success: \(response)"
            )
            return response
        } catch {
            await logger?.error(
                "Get user library sectioned for section \(T.self) items \(V.self): \(error.localizedDescription)"
            )
            return nil
        }
    }

    // TODO: Search suggestions requests
    // Though I am not sure it is needed
    // As I don't know how to make use of it in UI yet
}
