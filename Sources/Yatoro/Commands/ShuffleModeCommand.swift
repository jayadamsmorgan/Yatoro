import ArgumentParser
import MusicKit

struct ShuffleModeCommand: AsyncParsableCommand {

    @Argument
    var mode: MusicPlayer.ShuffleMode?

    @MainActor
    static func execute(arguments: Array<String>) async {
        do {
            let command = try RepeatModeCommand.parse(arguments)
            logger?.debug("New repeat mode command request: \(command)")
            if let mode = command.mode {
                Player.shared.player.state.repeatMode = mode
                logger?.debug("Player repeatMode: \(Player.shared.player.state.repeatMode ?? .none)")
            } else {
                // Toggle
                guard let currentMode = Player.shared.player.state.shuffleMode else {
                    Player.shared.player.state.shuffleMode = .songs
                    return
                }
                switch currentMode {
                case .off: Player.shared.player.state.shuffleMode = .songs
                case .songs: Player.shared.player.state.shuffleMode = .off
                @unknown default: logger?.error("RepeatModeCommand: Unhandled mode.")
                }
            }
        } catch {
            if let error = error as? CommandError {
                switch error.parserError {
                case .userValidationError(let validationError):
                    let validationError = validationError as! ValidationError
                    let msg = validationError.message
                    logger?.debug("CommandParser: repeatModeCommand: \(msg)")
                    await CommandInput.shared.setLastCommandOutput(msg)
                default:
                    let msg = "Error: wrong arguments"
                    logger?.debug("CommandParser: repeatModeCommand: \(msg)")
                    await CommandInput.shared.setLastCommandOutput(msg)
                }
            }
        }
    }

}
