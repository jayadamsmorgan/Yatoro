extension Config {

    public struct Settings {

        var disableSigInt: Bool
        var disableResize: Bool
        var searchItemLimit: UInt32

        public init() {
            self.disableSigInt = false
            self.disableResize = false
            self.searchItemLimit = 10
        }

    }
}

extension Config.Settings: Codable {

    enum CodingKeys: String, CodingKey {
        case disableSigInt
        case disableResize
        case searchItemLimit
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.disableSigInt =
            try container.decodeIfPresent(Bool.self, forKey: .disableSigInt) ?? false
        self.disableResize =
            try container.decodeIfPresent(Bool.self, forKey: .disableResize) ?? false
        self.searchItemLimit =
            try container.decodeIfPresent(UInt32.self, forKey: .searchItemLimit) ?? 10
    }

}
