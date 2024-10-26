# Commands
**Note**: commands are subject to change

Yatoro has a command mode which could be triggered by `:` key.

Here are the available commands for the command mode and their description:

| Command                   | Short | Description                                                   |
| ------------------------- | ----- | ------------------------------------------------------------- |
| `addToQueue`              |  `a`  | [See addToQueue](##addToQueue)                                           |
| `clearQueue`              |  `c`  | Clear playing queue                                           |
| `pause`                   | `pa`  | Pause                                                         |
| `play`                    | `pl`  | Continue playing                                              |
| `playNext`                |  `pn` | Play next item in queue                                       |
| `playPauseToggle`         | `pp`  | Play/pause toggle                                             |
| `playPrevious`            |  `b`  | Play previous song                                            |
| `quitApplication`         |  `q`  | Quit Yatoro application                                       |
| `restartSong`             |  `r`  | Restart song                                                  |
| `search`                  |  `/`  | [See search](##search)                                        |
| `setSongTime`             | `set` | [See setSongTime](##setSongTime)                                              |
| `startSeekingBackward`    | `sb`  | Start seeking backward                                        |
| `startSeekingForward`     |  `sf` | Start seeking forward                                         |
| `stationFromCurrentEntry` | `sce` | Creates station from current queue entry and adds it to queue |
| `stop`                    |  `s`  | Stop playing                                                  |
| `stopSeeking`             | `ss`  | Stop seeking                                                  |

## addToQueue
Used to add items to player queue.

Add to queue command expects 2 arguments and 1 flag:

- `from` --- **(Flag)**
    - `-c`, `--catalogSearchSongs` - add songs from catalog search
    - `-l`, `--librarySearchSongs` - add songs from user library search
    - `-r`, `--recentlyPlayedSongs` - add songs from recently played request
    - `-s`, `--recommended` - add songs from user recommendation request

- `item` --- **(Argument 1)** --- This argument is used to specify what you want to add to queue:
    - either an index of item, e.g. `1`
    - indices of items separated by commas, e.g. `0,3,5`
    - or `all` (`a`) to add all items from the request

**Note**: Indices are 0 based.

- `to` --- **(Argument 2)** --- This argument is used to specify where to add to the queue:
    - `tail`, `end`, `later`, `t`, `e`, `l` - add the selected items to the end of the queue
    - `next`, `afterCurrentEntry`, `n`, `a` - add the selected items right after currently playing item 

Example: `:a -l a n` --- Add all items from library song search after currently playing entry

## search
Used to make search requests.

Search command expects 1 optional argument and 1 optional flag:

- `from` --- **(Flag)**
    - `-c`, `--catalogSearchSongs` - search from catalog songs **(Default)**
    - `-l`, `--librarySearchSongs` - search from user library songs
    - `-r`, `--recentlyPlayedSongs` - request recently played songs
    - `-s`, `--recommended` - user recommendations request

- `searchPhrase` --- **(Argument)**

**Note**: Search phrase is not needed when requesting recently played songs or user recommendations but required when searching catalog or user library songs.

Example: `:search TOOL lateralus` - Search catalog songs for "TOOL lateralus"

## setSongTime
Sets playback time for the current entry.

Set song time command expects 1 argument and 1 optional flag:

- `-r`, `relative` --- **(Flag)** --- This flag is used to treat the argument as relative time to the current playback time **(Default: false)**

- `time` --- **(Argument)** --- This argument can be expressed:
    - either in seconds, e.g. `13`, `-10`, `232`
    - either in "MM:SS" format, e.g. `00:23`, `1:16`
    - or in "HH:MM:SS" format, e.g. `1:42:01`

**Note**: Time argument can be negative only when `-r` flag is passed.

