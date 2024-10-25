extension Config.UIConfig.Colors {

    public struct Item {
        public var page: ColorPair
        public var border: ColorPair
        public var pageName: ColorPair
        public var artistLeft: ColorPair
        public var artistRight: ColorPair
        public var songLeft: ColorPair
        public var songRight: ColorPair
        public var albumLeft: ColorPair
        public var albumRight: ColorPair
        public var playlistLeft: ColorPair
        public var playlistRight: ColorPair
        public var radioLeft: ColorPair
        public var radioRight: ColorPair
        public var suggestionLeft: ColorPair
        public var suggestionRight: ColorPair
        public var duration: ColorPair

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
            self.playlistLeft = .init()
            self.playlistRight = .init()
            self.radioLeft = .init()
            self.radioRight = .init()
            self.suggestionLeft = .init()
            self.suggestionRight = .init()
            self.duration = .init()
        }
    }
}

extension Config.UIConfig.Colors.Item: Codable {

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
        case playlistLeft
        case playlistRight
        case radioLeft
        case radioRight
        case suggestionLeft
        case suggestionRight
        case duration
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
        self.playlistLeft =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .playlistLeft)
            ?? .init()
        self.playlistRight =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .playlistRight)
            ?? .init()
        self.radioLeft =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .radioLeft)
            ?? .init()
        self.radioRight =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .radioRight)
            ?? .init()
        self.suggestionLeft =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .suggestionLeft)
            ?? .init()
        self.suggestionRight =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .suggestionRight)
            ?? .init()
        self.duration =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .duration)
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
        try container.encode(self.playlistLeft, forKey: .playlistLeft)
        try container.encode(self.playlistRight, forKey: .playlistRight)
        try container.encode(self.radioLeft, forKey: .radioLeft)
        try container.encode(self.radioRight, forKey: .radioRight)
        try container.encode(self.suggestionLeft, forKey: .suggestionLeft)
        try container.encode(self.suggestionRight, forKey: .suggestionRight)
        try container.encode(self.duration, forKey: .duration)
    }

}
