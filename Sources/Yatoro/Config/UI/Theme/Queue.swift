extension Theme {

    public struct Queue {
        public var page: ColorPair
        public var border: ColorPair
        public var pageName: ColorPair

        public var shuffleMode: ColorPair
        public var repeatMode: ColorPair

        public var songItem: SongItem

        public init() {
            self.page = .init()
            self.border = .init()
            self.pageName = .init()
            self.songItem = .init()
            self.shuffleMode = .init()
            self.repeatMode = .init()
        }
    }
}

extension Theme.Queue: Codable {

    enum CodingKeys: String, CodingKey {
        case page
        case border
        case pageName
        case shuffleMode
        case repeatMode

        case songItem
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.page =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .page)
            ?? .init()
        self.pageName =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .pageName)
            ?? .init()
        self.border =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .border)
            ?? .init()
        self.songItem =
            try container.decodeIfPresent(Theme.SongItem.self, forKey: .songItem)
            ?? .init()
        self.shuffleMode =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .shuffleMode)
            ?? .init()
        self.repeatMode =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .repeatMode)
            ?? .init()
    }

}
