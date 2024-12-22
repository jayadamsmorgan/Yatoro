extension Theme {

    public struct AlbumItem {
        public var page: ColorPair
        public var border: ColorPair
        public var pageName: ColorPair
        public var artistLeft: ColorPair
        public var artistRight: ColorPair
        public var albumLeft: ColorPair
        public var albumRight: ColorPair
        public var genreLeft: ColorPair
        public var genreRight: ColorPair

        public init() {
            self.page = .init()
            self.border = .init()
            self.pageName = .init()
            self.artistLeft = .init()
            self.artistRight = .init()
            self.albumLeft = .init()
            self.albumRight = .init()
            self.genreLeft = .init()
            self.genreRight = .init()
        }
    }
}

extension Theme.AlbumItem: Codable {

    enum CodingKeys: String, CodingKey {
        case page
        case border
        case pageName
        case artistLeft
        case artistRight
        case albumLeft
        case albumRight
        case genreLeft
        case genreRight
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
        self.albumLeft =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .albumLeft)
            ?? .init()
        self.albumRight =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .albumRight)
            ?? .init()
        self.genreLeft =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .genreLeft)
            ?? .init()
        self.genreRight =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .genreRight)
            ?? .init()
    }

}
