extension Config.UIConfig.Colors {

    public struct PlaylistItem {
        public var page: ColorPair
        public var border: ColorPair
        public var pageName: ColorPair
        public var playlistLeft: ColorPair
        public var playlistRight: ColorPair
        public var curatorLeft: ColorPair
        public var curatorRight: ColorPair
        public var descriptionLeft: ColorPair
        public var descriptionRight: ColorPair

        public init() {
            self.page = .init()
            self.border = .init()
            self.pageName = .init()
            self.playlistLeft = .init()
            self.playlistRight = .init()
            self.curatorLeft = .init()
            self.curatorRight = .init()
            self.descriptionLeft = .init()
            self.descriptionRight = .init()
        }
    }
}

extension Config.UIConfig.Colors.PlaylistItem: Codable {

    enum CodingKeys: String, CodingKey {
        case page
        case border
        case pageName
        case playlistLeft
        case playlistRight
        case curatorLeft
        case curatorRight
        case descriptionLeft
        case descriptionRight
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
        self.playlistLeft =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .playlistLeft)
            ?? .init()
        self.playlistRight =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .playlistRight)
            ?? .init()
        self.curatorLeft =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .curatorLeft)
            ?? .init()
        self.curatorRight =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .curatorRight)
            ?? .init()
        self.descriptionLeft =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .descriptionLeft)
            ?? .init()
        self.descriptionRight =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .descriptionRight)
            ?? .init()
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.page, forKey: .page)
        try container.encode(self.pageName, forKey: .pageName)
        try container.encode(self.border, forKey: .border)
        try container.encode(self.playlistLeft, forKey: .playlistLeft)
        try container.encode(self.playlistRight, forKey: .playlistRight)
        try container.encode(self.curatorLeft, forKey: .curatorLeft)
        try container.encode(self.curatorRight, forKey: .curatorRight)
        try container.encode(self.descriptionLeft, forKey: .descriptionLeft)
        try container.encode(self.descriptionRight, forKey: .descriptionRight)
    }

}
