import SwiftNotCurses

extension Config.UIConfig {

    public struct Artwork {

        public var blit: Visual.BlitConfig

        public var width: UInt32
        public var height: UInt32

        public init() {
            self.width = 500
            self.height = 500
            self.blit = .default
        }
    }
}

extension Config.UIConfig.Artwork: Codable {

    enum CodingKeys: String, CodingKey {
        case width
        case height
        case blit
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.width =
            try container.decodeIfPresent(UInt32.self, forKey: .width) ?? 500
        self.height =
            try container.decodeIfPresent(UInt32.self, forKey: .height) ?? 500

        self.blit =
            try container.decodeIfPresent(Visual.BlitConfig.self, forKey: .blit) ?? .default
    }

}
