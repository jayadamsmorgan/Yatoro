extension Config.UIConfig {

    public struct Artwork {
        public var width: UInt32
        public var height: UInt32

        public init() {
            self.width = 500
            self.height = 500
        }
    }
}

extension Config.UIConfig.Artwork: Codable {

    enum CodingKeys: String, CodingKey {
        case width
        case height
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.width =
            try container.decodeIfPresent(UInt32.self, forKey: .width) ?? 500
        self.height =
            try container.decodeIfPresent(UInt32.self, forKey: .height) ?? 500
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.width, forKey: .width)
        try container.encode(self.height, forKey: .height)
    }

}
