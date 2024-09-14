import AVFoundation
import Logging
import MusicKit

let player = AVPlayer()

@MainActor
@available(macOS 12.0, *)
public struct MusicPlayer {
    private var logger: Logger?

    public init(logger: Logger? = nil) {
        self.logger = logger
    }

    // Request permission to use Apple Music
    mutating func requestMusicAuthorization() async -> Bool {
        let status = await MusicAuthorization.request()
        return status == .authorized
    }

    // Search for a song using MusicKit
    mutating func fetchSong(using searchTerm: String) async throws -> MusicItemCollection<Song>? {
        let searchRequest = MusicCatalogSearchRequest(term: searchTerm, types: [Song.self])
        let searchResponse = try await searchRequest.response()
        return searchResponse.songs
    }

    // Play the first song from the search results
    mutating func play(song: Song) {
        guard let url = song.previewAssets?.first?.url else {
            print("No preview available for the song.")
            return
        }

        // Initialize AVPlayer with the song URL
        print(url)

        var headRequest = URLRequest(url: url)
        headRequest.httpMethod = "HEAD"

        URLSession.shared.dataTask(
            with: headRequest,
            completionHandler: { data, response, error in
                guard let httpResponse = response as? HTTPURLResponse else { return }
                print("Headers for \(url)")

                for (key, value) in httpResponse.allHeaderFields {
                    if let stringKey = key as? String, let stringValue = value as? String {
                        print("Header \(stringKey): \(stringValue)")
                    }
                }
            }
        ).resume()
        let item = AVPlayerItem(
            asset: AVURLAsset(url: url),
            automaticallyLoadedAssetKeys: ["duration", "playable"]
        )

        player.replaceCurrentItem(with: item)
        player.automaticallyWaitsToMinimizeStalling = false
        player.isMuted = false
        player.play()
        print("PLAYING")
    }
}
