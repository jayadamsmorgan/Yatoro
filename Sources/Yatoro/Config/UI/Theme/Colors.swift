import Foundation
import SwiftNotCurses

extension Theme {

    public struct ColorPair: Codable {
        var foreground: Plane.Color?
        var background: Plane.Color?

        public init() {
            self.foreground = nil
            self.background = nil
        }

        public enum CodingKeys: String, CodingKey {
            case fg
            case bg
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if let fgStr = try container.decodeIfPresent(String.self, forKey: .fg) {
                if let defaultColor = Plane.Color.DefaultColors(rawValue: fgStr) {
                    self.foreground = .init(color: defaultColor)
                } else {
                    self.foreground = .init(hex: fgStr)
                }
            }
            if let bgStr = try container.decodeIfPresent(String.self, forKey: .bg) {
                if let defaultColor = Plane.Color.DefaultColors(rawValue: bgStr) {
                    self.background = .init(color: defaultColor)
                } else {
                    self.background = .init(hex: bgStr)
                }
            }
        }

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            if let foreground {
                switch foreground.type {
                case .palette:
                    try container.encode(foreground.paletteName, forKey: .fg)
                case .rgb:
                    try container.encode(foreground, forKey: .fg)
                }
            }
            if let background {
                switch background.type {
                case .palette:
                    try container.encode(background.paletteName, forKey: .bg)
                case .rgb:
                    try container.encode(background, forKey: .bg)
                }
            }
        }
    }

}

extension Plane.Color: Codable {

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.red, forKey: .r)
        try container.encode(self.green, forKey: .g)
        try container.encode(self.blue, forKey: .b)
    }

    enum CodingKeys: String, CodingKey {
        case r
        case red

        case g
        case green

        case b
        case blue
    }

    public init(from decoder: any Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.red =
            try container.decodeIfPresent(UInt8.self, forKey: .r)
            ?? container.decodeIfPresent(UInt8.self, forKey: .red)
            ?? 0
        self.green =
            try container.decodeIfPresent(UInt8.self, forKey: .g)
            ?? container.decodeIfPresent(UInt8.self, forKey: .green)
            ?? 0
        self.blue =
            try container.decodeIfPresent(UInt8.self, forKey: .b)
            ?? container.decodeIfPresent(UInt8.self, forKey: .blue)
            ?? 0
    }

    public init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if hexSanitized.hasPrefix("#") {
            hexSanitized.remove(at: hexSanitized.startIndex)
        }

        guard hexSanitized.count == 6 else {
            return nil
        }

        var rgbValue: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgbValue)

        self.init()
        self.red = UInt8((rgbValue & 0xFF0000) >> 16)
        self.green = UInt8((rgbValue & 0x00FF00) >> 8)
        self.blue = UInt8(rgbValue & 0x0000FF)
    }

}
