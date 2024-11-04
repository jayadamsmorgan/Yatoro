extension Config.UIConfig.Colors {

    public struct SongItem {
        public var page: ColorPair
        public var border: ColorPair
        public var pageName: ColorPair
        public var artistLeft: ColorPair
        public var artistRight: ColorPair
        public var songLeft: ColorPair
        public var songRight: ColorPair
        public var albumLeft: ColorPair
        public var albumRight: ColorPair

        public init() {
            self.page = .init()
            self.border = .init()
            self.pageName = .init()
            self.artistLeft = .init()
            self.artistRight = .init()
            self.songLeft = .init()
            self.songRight = .init()
            self.albumLeft = .init()
            self.albumRight = .init()
        }
    }
}

extension Config.UIConfig.Colors.SongItem: Codable {

    enum CodingKeys: String, CodingKey {
        case page
        case border
        case pageName
        case artistLeft
        case artistRight
        case songLeft
        case songRight
        case albumLeft
        case albumRight
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
        self.songLeft =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .songLeft)
            ?? .init()
        self.songRight =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .songRight)
            ?? .init()
        self.albumLeft =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .albumLeft)
            ?? .init()
        self.albumRight =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .albumRight)
            ?? .init()
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.page, forKey: .page)
        try container.encode(self.pageName, forKey: .pageName)
        try container.encode(self.border, forKey: .border)
        try container.encode(self.artistLeft, forKey: .artistLeft)
        try container.encode(self.artistRight, forKey: .artistRight)
        try container.encode(self.songLeft, forKey: .songLeft)
        try container.encode(self.songRight, forKey: .songRight)
        try container.encode(self.albumLeft, forKey: .albumLeft)
        try container.encode(self.albumRight, forKey: .albumRight)
    }

}
