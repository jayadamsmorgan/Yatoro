extension Config.UIConfig.Colors {

    public struct RecommendationItem {
        public var page: ColorPair
        public var border: ColorPair
        public var pageName: ColorPair
        public var titleLeft: ColorPair
        public var titleRight: ColorPair
        public var refreshDateLeft: ColorPair
        public var refreshDateRight: ColorPair
        public var typesLeft: ColorPair
        public var typesRight: ColorPair

        public init() {
            self.page = .init()
            self.border = .init()
            self.pageName = .init()
            self.refreshDateLeft = .init()
            self.refreshDateRight = .init()
            self.typesLeft = .init()
            self.typesRight = .init()
            self.titleLeft = .init()
            self.titleRight = .init()
        }
    }
}

extension Config.UIConfig.Colors.RecommendationItem: Codable {

    enum CodingKeys: String, CodingKey {
        case page
        case border
        case pageName
        case titleLeft
        case titleRight
        case refreshDateLeft
        case refreshDateRight
        case typesLeft
        case typesRight
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
        self.refreshDateLeft =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .refreshDateLeft)
            ?? .init()
        self.refreshDateRight =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .refreshDateRight)
            ?? .init()
        self.typesLeft =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .typesLeft)
            ?? .init()
        self.typesRight =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .typesRight)
            ?? .init()
        self.titleLeft =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .titleLeft)
            ?? .init()
        self.titleRight =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .titleRight)
            ?? .init()
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.page, forKey: .page)
        try container.encode(self.pageName, forKey: .pageName)
        try container.encode(self.border, forKey: .border)
        try container.encode(self.titleLeft, forKey: .titleLeft)
        try container.encode(self.titleRight, forKey: .titleRight)
        try container.encode(self.refreshDateLeft, forKey: .refreshDateLeft)
        try container.encode(self.refreshDateRight, forKey: .refreshDateRight)
        try container.encode(self.typesLeft, forKey: .typesLeft)
        try container.encode(self.typesRight, forKey: .typesRight)
    }

}
