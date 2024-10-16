extension Config.UIConfig.Colors {

    public struct NowPlaying {
        public var page: ColorPair
        public var border: ColorPair
        public var pageName: ColorPair
        public var slider: ColorPair
        public var sliderKnob: ColorPair
        public var controls: ColorPair
        public var itemDescriptionLeft: ColorPair
        public var itemDescriptionRight: ColorPair

        public init() {
            self.page = .init()
            self.border = .init()
            self.pageName = .init()
            self.slider = .init()
            self.sliderKnob = .init()
            self.controls = .init()
            self.itemDescriptionLeft = .init()
            self.itemDescriptionRight = .init()
        }
    }
}

extension Config.UIConfig.Colors.NowPlaying: Codable {

    enum CodingKeys: String, CodingKey {
        case page
        case pageName
        case border
        case slider
        case sliderKnob
        case controls

        case itemDescLeft

        case itemDescRight
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.page =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .page)
            ?? .init()
        self.pageName =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .pageName)
            ?? .init()
        self.border =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .border)
            ?? .init()
        self.slider =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .slider)
            ?? .init()
        self.sliderKnob =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .sliderKnob)
            ?? .init()
        self.itemDescriptionLeft =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .itemDescLeft)
            ?? .init()
        self.itemDescriptionRight =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .itemDescRight)
            ?? .init()
        self.controls =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .controls)
            ?? .init()
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.page, forKey: .page)
        try container.encode(self.pageName, forKey: .pageName)
        try container.encode(self.border, forKey: .border)
        try container.encode(self.itemDescriptionLeft, forKey: .itemDescLeft)
        try container.encode(self.itemDescriptionRight, forKey: .itemDescRight)
        try container.encode(self.slider, forKey: .slider)
        try container.encode(self.sliderKnob, forKey: .sliderKnob)
        try container.encode(self.controls, forKey: .controls)
    }

}
