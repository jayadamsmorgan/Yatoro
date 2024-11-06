import ArgumentParser
import MusicKit

struct RepeatModeCommand: AsyncParsableCommand {

    @Argument
    var mode: MusicPlayer.RepeatMode?

    @MainActor
    static func execute(arguments: Array<String>) async {
        do {
            let command = try RepeatModeCommand.parse(arguments)
            logger?.debug("New repeat mode command request: \(command)")
            if let mode = command.mode {
                Player.shared.player.state.repeatMode = mode
                logger?.debug("Player repeatMode: \(Player.shared.player.state.repeatMode ?? .none)")
            } else {
                // Change to the next mode
                guard let currentMode = Player.shared.player.state.repeatMode else {
                    Player.shared.player.state.repeatMode = .all
                    return
                }
                switch currentMode {
                case .none: Player.shared.player.state.repeatMode = .all
                case .one: Player.shared.player.state.repeatMode = MusicPlayer.RepeatMode.none
                case .all: Player.shared.player.state.repeatMode = .one
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
