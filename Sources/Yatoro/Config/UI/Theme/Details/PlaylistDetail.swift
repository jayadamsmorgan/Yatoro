extension Theme {

    public struct PlaylistDetail {
        public var page: ColorPair
        public var border: ColorPair
        public var songIndices: ColorPair
        public var playlistTitle: ColorPair
        public var songsText: ColorPair

        public var songItem: SongItem

        public init() {
            self.page = .init()
            self.border = .init()
            self.songIndices = .init()
            self.playlistTitle = .init()
            self.songsText = .init()

            self.songItem = .init()
        }
    }
}

extension Theme.PlaylistDetail: Codable {

    enum CodingKeys: String, CodingKey {
        case page
        case border
        case songIndices
        case playlistTitle
        case songsText
        case songItem
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.page =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .page)
            ?? .init()
        self.border =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .border)
            ?? .init()
        self.songIndices =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .songIndices)
            ?? .init()
        self.playlistTitle =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .playlistTitle)
            ?? .init()
        self.songsText =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .songsText)
            ?? .init()

        self.songItem =
            try container.decodeIfPresent(Theme.SongItem.self, forKey: .songItem)
            ?? .init()
    }

}
