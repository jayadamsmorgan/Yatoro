import Foundation
import notcurses

public extension Plane {

    struct Color: Sendable {

        public enum ColorType: Sendable, Codable {
            case palette
            case rgb
        }

        public var type: ColorType
        public var paletteIndex: UInt8

        public var red: UInt8
        public var green: UInt8
        public var blue: UInt8

        public var alpha: UInt8

        public enum DefaultColors: String {
            case black
            case red
            case green
            case yellow
            case blue
            case magenta
            case cyan
            case white
            case brightBlack
            case brightRed
            case brightGreen
            case brightYellow
            case brightBlue
            case brightMagenta
            case brightCyan
            case brightWhite
        }

        public var paletteName: String {
            switch self.paletteIndex {
            case 0: return "black"
            case 1: return "red"
            case 2: return "green"
            case 3: return "yellow"
            case 4: return "blue"
            case 5: return "magenta"
            case 6: return "cyan"
            case 7: return "white"
            case 8: return "brightBlack"
            case 9: return "brightRed"
            case 10: return "brightGreen"
            case 11: return "brightYellow"
            case 12: return "brightBlue"
            case 13: return "brightMagenta"
            case 14: return "brightCyan"
            case 15: return "brightWhite"
            default: return "unknownPalette\(paletteIndex)"
            }
        }

        public init() {
            self.red = 0
            self.green = 0
            self.blue = 0

            self.alpha = 255
            self.type = .rgb
            self.paletteIndex = 0
        }

        public init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8 = 255) {
            self.red = red
            self.green = green
            self.blue = blue

            self.alpha = alpha
            self.type = .rgb
            self.paletteIndex = 0
        }

        public init(rgb: (red: UInt8, green: UInt8, blue: UInt8), alpha: UInt8 = 255) {
            self.red = rgb.red
            self.green = rgb.green
            self.blue = rgb.blue

            self.alpha = alpha
            self.type = .rgb
            self.paletteIndex = 0
        }

        public init?(color: String) {
            guard let color = DefaultColors.init(rawValue: color) else {
                return nil
            }
            self.init(color: color)
        }

        public init(color: DefaultColors) {
            var channel: UInt8
            switch color {
            case .black: channel = 0
            case .red: channel = 1
            case .green: channel = 2
            case .yellow: channel = 3
            case .blue: channel = 4
            case .magenta: channel = 5
            case .cyan: channel = 6
            case .white: channel = 7
            case .brightBlack: channel = 8
            case .brightRed: channel = 9
            case .brightGreen: channel = 10
            case .brightYellow: channel = 11
            case .brightBlue: channel = 12
            case .brightMagenta: channel = 13
            case .brightCyan: channel = 14
            case .brightWhite: channel = 15
            }
            self.paletteIndex = channel
            self.type = .palette
            self.red = 0
            self.green = 0
            self.blue = 0
            self.alpha = 255
        }
    }

}
