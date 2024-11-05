import ArgumentParser
import MusicKit

struct AddToQueueCommand: AsyncParsableCommand {

    @Argument
    var item: SearchItemIndex

    @Argument
    var to: ApplicationMusicPlayer.Queue.EntryInsertionPosition = .tail

}
