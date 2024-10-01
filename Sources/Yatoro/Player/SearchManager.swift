import Foundation
import Logging
import MusadoraKit

public struct SearchResult {

    public let timestamp: Date

    public let type: SearchType

    public let searchPhrase: String?

    public let result: AnyMusicItemCollection

}

public protocol AnyMusicItemCollection {}
extension MusicItemCollection: AnyMusicItemCollection where Element: MusicItem {
    public func item(at index: Int) -> any MusicItem {
        return self[index]
    }
}

public enum SearchType: Hashable {
    case recentlyPlayedSongs
    case recommended
    case catalogSearchSongs
    case librarySearchSongs
}

public class SearchManager {

    public static let shared: SearchManager = .init()

    public var logger: Logger?

    public var lastSearchResults: [SearchType: SearchResult] = [:]

    private init() {}

    public func newSearch(for phrase: String? = nil, in type: SearchType) async
    {
        var result: AnyMusicItemCollection?

        switch type {

        case .recentlyPlayedSongs:
            let res: MusicItemCollection<Song>? =
                await getRecentlyPlayed()
            result = res

        case .recommended:
            result = await getUserRecommendedBatch()

        case .catalogSearchSongs:
            guard let phrase else { return }
            let res: MusicItemCollection<Song>? = await searchCatalogBatch(
                for: phrase
            )
            result = res

        case .librarySearchSongs:
            guard let phrase else { return }
            let res: MusicItemCollection<Song>? = await searchUserLibraryBatch(
                for: phrase
            )
            result = res

        }
        guard let result else { return }

        self.lastSearchResults[type] = .init(
            timestamp: Date.now,
            type: type,
            searchPhrase: nil,
            result: result
        )

    }

}

// Requesting
public extension SearchManager {

    func getRecentlyPlayed<T>(limit: Int = 10) async
        -> MusicItemCollection<T>?
    where T: Decodable, T: MusicRecentlyPlayedRequestable {
        logger?.trace(
            "Get recently played for \(T.self): Requesting with limit \(limit)..."
        )
        var request = MusicRecentlyPlayedRequest<T>()
        request.limit = limit
        do {
            let response = try await request.response()
            logger?.debug("Recently played response success: \(response)")
            return response.items
        } catch {
            logger?.error(
                "Failed to make recently played request: \(error.localizedDescription)"
            )
            return nil
        }
    }

    func getRecentlyPlayedContainer(limit: Int = 10) async
        -> MusicItemCollection<RecentlyPlayedMusicItem>?
    {
        logger?.trace(
            "Get recently played container: Requesting with limit \(limit)..."
        )
        var request = MusicRecentlyPlayedContainerRequest()
        request.limit = limit
        do {
            let response = try await request.response()
            logger?.debug(
                "Recently played container response success: \(response)"
            )
            return response.items
        } catch {
            logger?.error(
                "Failed to make recently played container request: \(error.localizedDescription)"
            )
            return nil
        }
    }

    func getUserRecommendedBatch(
        limit: Int = 10
    ) async -> MusicItemCollection<MusicPersonalRecommendation>? {
        logger?.trace(
            "Get user recommended batch: Requesting with limit \(limit)..."
        )
        var request = MusicPersonalRecommendationsRequest()
        request.limit = limit
        do {
            let response = try await request.response()
            logger?.debug("Get user recommended batch: success: \(response)")
            return response.recommendations
        } catch {
            logger?.error(
                "Failed to get user recommended batch: \(error.localizedDescription)"
            )
            return nil
        }
    }

    func getUserLibraryBatch<T>(
        limit: Int = 10,
        onlyOfflineContent: Bool = false
    ) async -> MusicItemCollection<T>?
    where T: MusicLibraryRequestable {
        logger?.trace(
            "Get user library batch for \(T.self): Requesting with limit: \(limit), onlyOfflineContent: \(onlyOfflineContent)..."
        )
        var request = MusicLibraryRequest<T>()
        request.limit = limit
        request.includeOnlyDownloadedContent = onlyOfflineContent
        do {
            let response = try await request.response()
            logger?.debug("Get user library batch: success: \(response)")
            return response.items
        } catch {
            logger?.error(
                "Failed to make user library song request: \(error.localizedDescription)"
            )
            return nil
        }
    }

    func searchCatalogBatch<T>(
        for term: String,
        limit: Int = 10
    ) async -> MusicItemCollection<T>?
    where T: MusicCatalogSearchable {
        logger?.trace(
            "Search catalog batch for \(T.self): Requesting with term \(term), limit \(limit)..."
        )
        var request = MusicCatalogSearchRequest(term: term, types: [T.self])
        if T.self == CatalogTopResult.self {
            logger?.trace(
                "Search catalog batch for \(T.self): Including top results."
            )
            request.includeTopResults = true
        }
        request.limit = limit
        do {
            let response = try await request.response()
            logger?.trace(
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
                logger?.error(
                    "Failed to search catalog batch: Type \(T.self) is not supported."
                )
            }
            guard let collection else {
                logger?.error(
                    "Failed to search catalog batch: Unable to transform \(T.self) as \(T.self)"
                )
                return nil
            }
            logger?.debug(
                "Search catalog batch for \(T.self): Success: \(collection)"
            )
            return collection
        } catch {
            logger?.error(
                "Failed to search catalog batch for \(T.self): \(error.localizedDescription)"
            )
            return nil
        }
    }

    func searchUserLibraryBatch<T>(
        for term: String,
        limit: Int = 10
    ) async -> MusicItemCollection<T>?
    where T: MusicLibrarySearchable {
        logger?.trace(
            "Search user library batch for \(T.self): Requesting with term \(term), limit \(limit)..."
        )
        var request = MusicLibrarySearchRequest(term: term, types: [T.self])
        if T.self == LibraryTopResult.self {
            logger?.trace(
                "Search user library batch for \(T.self): Including top results."
            )
            request.includeTopResults = true
        }
        request.limit = limit
        do {
            let response = try await request.response()
            logger?.trace("")
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
                logger?.error(
                    "Search user library failed: Unsupported type \(T.self)."
                )
                return nil
            }
            guard let collection else {
                logger?.error(
                    "Search user library failed: Unable to transform \(T.self) type as \(T.self) type."
                )
                return nil
            }
            logger?.debug(
                "Searching user library for \(T.self): success: \(collection)"
            )
            return collection
        } catch {
            logger?.error(
                "Failed to search user library: Request error: \(error.localizedDescription)"
            )
            return nil
        }
    }

    func getAllCatalogCharts(limit: Int = 10) async
        -> MusicCatalogChartsResponse?
    {
        logger?.trace("Get all catalog charts: Requesting...")
        var request = MusicCatalogChartsRequest(types: [
            Song.self, Playlist.self, Album.self, MusicVideo.self,
        ])
        request.limit = limit
        do {
            let response = try await request.response()
            logger?.trace("Get all catalog charts: success: \(response)")
            return response
        } catch {
            logger?.error(
                "Failed to get all catalog charts: \(error.localizedDescription)"
            )
            return nil
        }
    }

    func getSpecificCatalogCharts<T>(
        limit: Int = 10
    ) async -> [MusicCatalogChart<T>]? where T: MusicCatalogChartRequestable {
        logger?.trace("Get catalog charts for type \(T.self): Requesting...")
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
                logger?.error(
                    "Failed to get catalog charts for type \(T.self): Unsupported type."
                )
                return nil
            }
            guard let result else {
                logger?.error(
                    "Failed to get catalog charts: Unable to transform \(T.self) as \(T.self)."
                )
                return nil
            }
            return result
        } catch {
            logger?.error(
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
            logger?.trace(
                "Previous batch does not have next batch."
            )
            return nil
        }
        do {
            let response = try await previousBatch.nextBatch(limit: limit)
            guard let response else {
                logger?.debug("Next batch is nil, should not happen.")
                return nil
            }
            logger?.trace("Next batch success: \(response)")
            return response
        } catch {
            logger?.error(
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
        logger?.trace(
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
            logger?.debug(
                "Get user library sectioned for section \(T.self) items \(V.self): success: \(response)"
            )
            return response
        } catch {
            logger?.error(
                "Get user library sectioned for section \(T.self) items \(V.self): \(error.localizedDescription)"
            )
            return nil
        }
    }

    // TODO: Search suggestions requests
    // Though I am not sure it is needed
    // As I don't know how to make use of it in UI yet
}
