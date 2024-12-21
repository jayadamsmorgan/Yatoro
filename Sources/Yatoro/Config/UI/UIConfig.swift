extension Config {

    public struct UIConfig {

        var margins: Margins
        var frameDelay: UInt64
        var layout: UILayoutConfig
        var artwork: Artwork

        var theme: String

        public init() {
            self.margins = .init()
            self.layout = .init()
            self.frameDelay = 5_000_000
            self.artwork = .init()

            self.theme = "default"
        }

        public struct Margins {
            public var all: UInt32
            public var left: UInt32?
            public var right: UInt32?
            public var top: UInt32?
            public var bottom: UInt32?

            public init() {
                self.all = 0
            }

        }
    }
}

extension Config.UIConfig: Codable {

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.margins =
            try container.decodeIfPresent(Margins.self, forKey: .margins) ?? .init()
        self.layout =
            try container.decodeIfPresent(UILayoutConfig.self, forKey: .layout) ?? .init()
        self.frameDelay =
            try container.decodeIfPresent(UInt64.self, forKey: .frameDelay) ?? 5_000_000
        self.artwork =
            try container.decodeIfPresent(Artwork.self, forKey: .artwork) ?? .init()

        self.theme =
            try container.decodeIfPresent(String.self, forKey: .theme) ?? "default"
    }

}

extension Config.UIConfig.Margins: Codable {

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.all =
            try container.decodeIfPresent(UInt32.self, forKey: .all) ?? 0
        self.left =
            try container.decodeIfPresent(UInt32.self, forKey: .left)
        self.right =
            try container.decodeIfPresent(UInt32.self, forKey: .right)
        self.top =
            try container.decodeIfPresent(UInt32.self, forKey: .top)
        self.bottom =
            try container.decodeIfPresent(UInt32.self, forKey: .bottom)
    }
}
