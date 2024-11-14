extension Config {

    public struct Settings {

        var disableSigInt: Bool

        public init() {
            self.disableSigInt = false
        }

    }
}

extension Config.Settings: Codable {

    enum CodingKeys: String, CodingKey {
        case disableSigInt
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.disableSigInt =
            try container.decodeIfPresent(Bool.self, forKey: .disableSigInt) ?? false
    }

}
