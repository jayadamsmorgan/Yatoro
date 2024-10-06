import ArgumentParser

struct SetSongTimeCommand: AsyncParsableCommand {

    @Flag(name: .shortAndLong)
    var relative: Bool = false

    @Argument
    var time: String

}
