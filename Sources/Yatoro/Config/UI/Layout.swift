extension Config.UIConfig {

    public struct UILayoutConfig {
        public var rows: UInt32
        public var cols: UInt32

        public var pages: [Pages]

        public enum Pages: String, Codable {
            case nowPlaying
            case queue
            case search
        }

        public init() {
            self.rows = 2
            self.cols = 2
            pages = [.nowPlaying, .search, .queue]
        }
    }
}

extension Config.UIConfig.UILayoutConfig: Codable {

    enum CodingKeys: String, CodingKey {
        case rows
        case cols
        case pages
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.rows =
            try container.decodeIfPresent(UInt32.self, forKey: .rows) ?? 2
        self.cols =
            try container.decodeIfPresent(UInt32.self, forKey: .cols) ?? 2
        self.pages =
            try container.decodeIfPresent([Pages].self, forKey: .pages) ?? [.nowPlaying, .search, .queue]
    }

}
