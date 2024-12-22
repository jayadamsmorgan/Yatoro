extension Theme {

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

extension Theme.PlaylistItem: Codable {

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
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .page)
            ?? .init()
        self.pageName =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .pageName)
            ?? .init()
        self.border =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .border)
            ?? .init()
        self.playlistLeft =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .playlistLeft)
            ?? .init()
        self.playlistRight =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .playlistRight)
            ?? .init()
        self.curatorLeft =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .curatorLeft)
            ?? .init()
        self.curatorRight =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .curatorRight)
            ?? .init()
        self.descriptionLeft =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .descriptionLeft)
            ?? .init()
        self.descriptionRight =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .descriptionRight)
            ?? .init()
    }

}
