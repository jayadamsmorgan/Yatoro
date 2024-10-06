import ArgumentParser
import MusicKit

struct AddToQueueCommand: AsyncParsableCommand {

    @Flag(exclusivity: .exclusive)
    var from: SearchType

    @Argument
    var item: SearchItemIndex

    @Argument
    var to: ApplicationMusicPlayer.Queue.EntryInsertionPosition = .tail

}
