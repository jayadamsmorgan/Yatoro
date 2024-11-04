extension Config.UIConfig.Colors {

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

extension Config.UIConfig.Colors.ArtistItem: Codable {

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
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .page)
            ?? .init()
        self.pageName =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .pageName)
            ?? .init()
        self.border =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .border)
            ?? .init()
        self.artistLeft =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .artistLeft)
            ?? .init()
        self.artistRight =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .artistRight)
            ?? .init()
        self.albumsLeft =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .albumsLeft)
            ?? .init()
        self.albumsRight =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .albumsRight)
            ?? .init()
        self.genreLeft =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .genreLeft)
            ?? .init()
        self.genreRight =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .genreRight)
            ?? .init()
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.page, forKey: .page)
        try container.encode(self.pageName, forKey: .pageName)
        try container.encode(self.border, forKey: .border)
        try container.encode(self.genreLeft, forKey: .genreLeft)
        try container.encode(self.genreRight, forKey: .genreRight)
        try container.encode(self.artistLeft, forKey: .artistLeft)
        try container.encode(self.artistRight, forKey: .artistRight)
        try container.encode(self.albumsLeft, forKey: .albumsLeft)
        try container.encode(self.albumsRight, forKey: .albumsRight)
    }

}
