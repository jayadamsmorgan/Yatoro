extension Config {

    public struct Settings {

        var disableSigInt: Bool
        var disableResize: Bool

        public init() {
            self.disableSigInt = false
            self.disableResize = false
        }

    }
}

extension Config.Settings: Codable {

    enum CodingKeys: String, CodingKey {
        case disableSigInt
        case disableResize
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.disableSigInt =
            try container.decodeIfPresent(Bool.self, forKey: .disableSigInt) ?? false
        self.disableResize =
            try container.decodeIfPresent(Bool.self, forKey: .disableResize) ?? false
    }

}
