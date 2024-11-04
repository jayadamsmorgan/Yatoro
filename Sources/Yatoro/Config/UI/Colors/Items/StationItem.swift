extension Config.UIConfig.Colors {

    public struct StationItem {
        public var page: ColorPair
        public var border: ColorPair
        public var pageName: ColorPair
        public var stationLeft: ColorPair
        public var stationRight: ColorPair
        public var isLiveLeft: ColorPair
        public var isLiveRight: ColorPair
        public var notesLeft: ColorPair
        public var notesRight: ColorPair

        public init() {
            self.page = .init()
            self.border = .init()
            self.pageName = .init()
            self.stationLeft = .init()
            self.stationRight = .init()
            self.isLiveLeft = .init()
            self.isLiveRight = .init()
            self.notesLeft = .init()
            self.notesRight = .init()
        }
    }
}

extension Config.UIConfig.Colors.StationItem: Codable {

    enum CodingKeys: String, CodingKey {
        case page
        case border
        case pageName
        case stationLeft
        case stationRight
        case isLiveLeft
        case isLiveRight
        case notesLeft
        case notesRight
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
        self.stationLeft =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .stationLeft)
            ?? .init()
        self.stationRight =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .stationRight)
            ?? .init()
        self.isLiveLeft =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .isLiveLeft)
            ?? .init()
        self.isLiveRight =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .isLiveRight)
            ?? .init()
        self.notesLeft =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .notesLeft)
            ?? .init()
        self.notesRight =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .notesRight)
            ?? .init()
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.page, forKey: .page)
        try container.encode(self.pageName, forKey: .pageName)
        try container.encode(self.border, forKey: .border)
        try container.encode(self.stationLeft, forKey: .stationLeft)
        try container.encode(self.stationRight, forKey: .stationRight)
        try container.encode(self.isLiveLeft, forKey: .isLiveLeft)
        try container.encode(self.isLiveRight, forKey: .isLiveRight)
        try container.encode(self.notesLeft, forKey: .notesLeft)
        try container.encode(self.notesRight, forKey: .notesRight)
    }

}
