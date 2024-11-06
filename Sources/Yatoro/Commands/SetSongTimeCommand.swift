import ArgumentParser

struct SetSongTimeCommand: AsyncParsableCommand {

    @Flag(name: .shortAndLong)
    var relative: Bool = false

    @Argument
    var time: String

    func validate() throws {
        let error = ValidationError("Error: Incorrect time format")
        if time.contains(":") {
            let splitted = time.split(separator: ":")
            guard splitted.count == 2 || splitted.count == 3 else {
                throw error
            }
            for part in splitted {
                guard Int(part) != nil else {
                    throw error
                }
            }
        } else if Int(time) == nil {
            throw error
        }
    }

    @MainActor
    static func execute(arguments: Array<String>) async {
        do {
            let command = try SetSongTimeCommand.parse(arguments)
            logger?.debug("New set song time command request: \(command)")

            guard command.time.contains(":") else {
                let seconds = Int(command.time)!

                await Player.shared.setTime(
                    seconds: seconds,
                    relative: command.relative
                )
                return
            }

            let split = command.time.split(separator: ":")

            switch split.count {
            case 2:  // MM:SS
                let minutesPart = Int(split[0])!
                let secondsPart = Int(split[1])!
                let seconds = minutesPart * 60 + secondsPart
                await Player.shared.setTime(
                    seconds: seconds,
                    relative: command.relative
                )

            case 3:  // HH:MM:SS
                let hoursPart = Int(split[0])!
                let minutesPart = Int(split[1])!
                let secondsPart = Int(split[2])!
                let seconds =
                    hoursPart * 60 * 60 + minutesPart * 60 + secondsPart
                await Player.shared.setTime(
                    seconds: seconds,
                    relative: command.relative
                )

            default: break
            }

        } catch {
            if let error = error as? CommandError {
                switch error.parserError {
                case .userValidationError(let validationError):
                    let validationError = validationError as! ValidationError
                    let msg = validationError.message
                    logger?.debug("CommandParser: setSongTime: \(msg)")
                    await CommandInput.shared.setLastCommandOutput(msg)
                default:
                    let msg = "Error: wrong arguments"
                    logger?.debug("CommandParser: setSongTime: \(msg)")
                    await CommandInput.shared.setLastCommandOutput(msg)
                }
            }
        }
    }

}
