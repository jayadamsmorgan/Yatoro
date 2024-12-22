extension Theme {

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

extension Theme.RecommendationItem: Codable {

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
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .page)
            ?? .init()
        self.pageName =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .pageName)
            ?? .init()
        self.border =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .border)
            ?? .init()
        self.refreshDateLeft =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .refreshDateLeft)
            ?? .init()
        self.refreshDateRight =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .refreshDateRight)
            ?? .init()
        self.typesLeft =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .typesLeft)
            ?? .init()
        self.typesRight =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .typesRight)
            ?? .init()
        self.titleLeft =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .titleLeft)
            ?? .init()
        self.titleRight =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .titleRight)
            ?? .init()
    }

}
