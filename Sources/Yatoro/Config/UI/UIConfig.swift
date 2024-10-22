extension Config {

    public struct UIConfig {

        var margins: Margins
        var frameDelay: UInt64
        var layout: UILayoutConfig
        var colors: Colors
        var artwork: Artwork

        public init() {
            self.margins = .init()
            self.layout = .init()
            self.frameDelay = 5_000_000
            self.colors = .init()
            self.artwork = .init()
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

    enum CodingKeys: String, CodingKey {
        case margins
        case layout
        case frameDelay
        case colors
        case artwork
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.margins =
            try container.decodeIfPresent(Margins.self, forKey: .margins) ?? .init()
        self.layout =
            try container.decodeIfPresent(UILayoutConfig.self, forKey: .layout) ?? .init()
        self.frameDelay =
            try container.decodeIfPresent(UInt64.self, forKey: .frameDelay) ?? 5_000_000
        self.colors =
            try container.decodeIfPresent(Colors.self, forKey: .colors) ?? .init()
        self.artwork =
            try container.decodeIfPresent(Artwork.self, forKey: .artwork) ?? .init()
    }

}

extension Config.UIConfig.Margins: Codable {

    enum CodingKeys: String, CodingKey {
        case all
        case left
        case right
        case top
        case bottom
    }

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
