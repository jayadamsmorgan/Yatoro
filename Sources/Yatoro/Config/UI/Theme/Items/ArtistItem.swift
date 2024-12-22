extension Theme {

    public struct ArtistItem {
        public var page: ColorPair
        public var border: ColorPair
        public var pageName: ColorPair
        public var genreLeft: ColorPair
        public var genreRight: ColorPair
        public var artistLeft: ColorPair
        public var artistRight: ColorPair
        public var albumsLeft: ColorPair
        public var albumsRight: ColorPair

        public init() {
            self.page = .init()
            self.border = .init()
            self.pageName = .init()
            self.artistLeft = .init()
            self.artistRight = .init()
            self.albumsLeft = .init()
            self.albumsRight = .init()
            self.genreLeft = .init()
            self.genreRight = .init()
        }
    }
}

extension Theme.ArtistItem: Codable {

    enum CodingKeys: String, CodingKey {
        case page
        case border
        case pageName
        case genreLeft
        case genreRight
        case artistLeft
        case artistRight
        case albumsLeft
        case albumsRight
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
        self.artistLeft =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .artistLeft)
            ?? .init()
        self.artistRight =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .artistRight)
            ?? .init()
        self.albumsLeft =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .albumsLeft)
            ?? .init()
        self.albumsRight =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .albumsRight)
            ?? .init()
        self.genreLeft =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .genreLeft)
            ?? .init()
        self.genreRight =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .genreRight)
            ?? .init()
    }

}
