import Foundation

extension TimeInterval {
    func toMMSS() -> String {
        let time = Int(self)
        let minutes = (time / 60) % 60
        let seconds = time % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
