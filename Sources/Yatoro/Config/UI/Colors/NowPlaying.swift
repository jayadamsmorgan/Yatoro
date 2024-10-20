extension Config.UIConfig.Colors {

    public struct NowPlaying {
        public var page: ColorPair
        public var border: ColorPair
        public var pageName: ColorPair
        public var slider: ColorPair
        public var sliderKnob: ColorPair
        public var controls: ColorPair
        public var artistLeft: ColorPair
        public var artistRight: ColorPair
        public var songLeft: ColorPair
        public var songRight: ColorPair
        public var albumLeft: ColorPair
        public var albumRight: ColorPair
        public var currentTime: ColorPair
        public var duration: ColorPair

        public init() {
            self.page = .init()
            self.border = .init()
            self.pageName = .init()
            self.slider = .init()
            self.sliderKnob = .init()
            self.controls = .init()
            self.artistLeft = .init()
            self.artistRight = .init()
            self.songLeft = .init()
            self.songRight = .init()
            self.albumLeft = .init()
            self.albumRight = .init()
            self.currentTime = .init()
            self.duration = .init()
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

        case artistLeft
        case artistRight
        case songLeft
        case songRight
        case albumLeft
        case albumRight
        case currentTime
        case duration
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
        self.controls =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .controls)
            ?? .init()

        self.artistLeft =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .artistLeft)
            ?? .init()
        self.artistRight =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .artistRight)
            ?? .init()
        self.songLeft =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .songLeft)
            ?? .init()
        self.songRight =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .songRight)
            ?? .init()
        self.albumLeft =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .albumLeft)
            ?? .init()
        self.albumRight =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .albumRight)
            ?? .init()
        self.currentTime =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .currentTime)
            ?? .init()
        self.duration =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .duration)
            ?? .init()
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.page, forKey: .page)
        try container.encode(self.pageName, forKey: .pageName)
        try container.encode(self.border, forKey: .border)
        try container.encode(self.slider, forKey: .slider)
        try container.encode(self.sliderKnob, forKey: .sliderKnob)
        try container.encode(self.controls, forKey: .controls)

        try container.encode(self.artistLeft, forKey: .artistLeft)
        try container.encode(self.artistRight, forKey: .artistRight)
        try container.encode(self.songLeft, forKey: .songLeft)
        try container.encode(self.songRight, forKey: .songRight)
        try container.encode(self.albumLeft, forKey: .albumLeft)
        try container.encode(self.albumRight, forKey: .albumRight)
        try container.encode(self.currentTime, forKey: .currentTime)
        try container.encode(self.duration, forKey: .duration)
    }

}
