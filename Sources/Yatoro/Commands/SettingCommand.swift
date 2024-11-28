import ArgumentParser
import Yams

struct SettingCommand: AsyncParsableCommand {

    @Argument
    var setting: [String]

    @MainActor
    static func execute(arguments: Array<String>) async {
        do {
            let command = try SettingCommand.parse(arguments)
            logger?.debug("New setting command request: \(command)")
            let setting = command.setting.joined(separator: " ")
            let decoder = YAMLDecoder()
            let newConfig: Config = try decoder.decode(from: setting)
        } catch {
            if let error = error as? CommandError {
                switch error.parserError {
                case .userValidationError(let validationError):
                    let validationError = validationError as! ValidationError
                    let msg = validationError.message
                    logger?.debug("CommandParser: setting: \(msg)")
                    await CommandInput.shared.setLastCommandOutput(msg)
                default:
                    let msg = "Error: wrong arguments"
                    logger?.debug("CommandParser: setting: \(msg)")
                    await CommandInput.shared.setLastCommandOutput(msg)
                }
            } else if let error = error as? DecodingError {
                let msg = "Decoding error: \(error)"
                logger?.debug("CommandParser: setting: \(msg)")
                await CommandInput.shared.setLastCommandOutput(msg)
            }
        }
    }

}
