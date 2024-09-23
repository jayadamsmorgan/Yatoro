import MusicKit
import Testing

@testable import Yatoro

struct MusicPlayerTests {

    init() async throws {
        await Player.shared.authorize()
    }

    @Test func getRecentlyPlayedSongs() async throws {
        let types: [any MusicRecentlyPlayedRequestable.Type] = [
            Song.self, Station.self,  // TODO: add more
        ]

        for type in types {
            let recentlyPlayed: MusicItemCollection<>? =
                await Player.shared.getRecentlyPlayed()
            #expect(recentlyPlayed != nil)
        }

    }
}
