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

}
