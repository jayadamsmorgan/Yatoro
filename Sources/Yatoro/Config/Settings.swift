extension Config {

    public struct Settings {

        var disableSigInt: Bool
        var disableResize: Bool
        var searchItemLimit: UInt32

        var disableITermWorkaround: Bool

        public init() {
            self.disableSigInt = false
            self.disableResize = false
            self.searchItemLimit = 10

            self.disableITermWorkaround = false
        }

    }
}

extension Config.Settings: Codable {

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.disableSigInt =
            try container.decodeIfPresent(Bool.self, forKey: .disableSigInt) ?? false
        self.disableResize =
            try container.decodeIfPresent(Bool.self, forKey: .disableResize) ?? false
        self.searchItemLimit =
            try container.decodeIfPresent(UInt32.self, forKey: .searchItemLimit) ?? 10

        self.disableITermWorkaround =
            try container.decodeIfPresent(Bool.self, forKey: .disableITermWorkaround) ?? false
    }

}
