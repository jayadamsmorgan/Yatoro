# Commands
**Note**: commands are subject to change

Yatoro has a command mode which could be triggered by `:` key.

Here are the available commands for the command mode and their description:

| Command                   | Short     | Description                                                   |
| ------------------------- | --------- | ------------------------------------------------------------- |
| `addToQueue`              | `a`       | [See addToQueue](#addToQueue)                                 |
| `clearQueue`              | `cq`      | Clear playing queue                                           |
| `close`                   | `c`       | Close last opened detailed page                               |
| `closeAll`                | `ca`      | Close all opened detailed pages                               |
| `open`                    | `o`       | [See open](#open)                                             |
| `pause`                   | `pa`      | Pause                                                         |
| `play`                    | `pl`      | Continue playing                                              |
| `playNext`                | `pn`      | Play next item in queue                                       |
| `playPauseToggle`         | `pp`      | Play/pause toggle                                             |
| `playPrevious`            | `b`       | Play previous song                                            |
| `quitApplication`         | `q`       | Quit Yatoro application                                       |
| `reloadConfig`            | `rel`     | Reload Yatoro configuration                                   |
| `repeatMode`              | `repeat`  | [See repeatMode](#repeatMode)                                 |
| `restartSong`             | `r`       | Restart song                                                  |
| `search`                  | `/`       | [See search](#search)                                         |
| `setSongTime`             | `time`    | [See setSongTime](#setSongTime)                               |
| `shuffleMode`             | `shuffle` | [See shuffleMode](#shuffleMode)                               |
| `startSeekingBackward`    | `sb`      | Start seeking backward                                        |
| `startSeekingForward`     | `sf`      | Start seeking forward                                         |
| `stationFromCurrentEntry` | `sce`     | Creates station from current queue entry and adds it to queue |
| `stop`                    | `s`       | Stop playing                                                  |
| `stopSeeking`             | `ss`      | Stop seeking                                                  |

Command completions can be activated with `TAB` while in command mode.
Press `TAB` or right arrow to cycle completions forward, `SHIFT+TAB` or left arrow to cycle backwards.

To cycle through command history press arrow up or down while in command mode.

## addToQueue
Used to add items to player queue from search page.

Add to queue command expects 2 arguments:

- `item` --- **(Argument 1)** --- This argument is used to specify what you want to add to queue:
    - either an index of item, e.g. `1`
    - indices of items separated by commas, e.g. `0,3,5`
    - or `all` (`a`) to add all items from the request

- `to` --- **(Argument 2)** --- This argument is used to specify where to add to the queue:
    - `tail`, `end`, `later`, `t`, `e`, `l` - add the selected items to the end of the queue **(Default)**
    - `next`, `afterCurrentEntry`, `n`, `a` - add the selected items right after currently playing item 

**Note**: Some items such as user recommendations have to be opened with [open](#open) first to be able to add items to queue

Examples:
    - `:a a n` --- Add all items from current search after currently playing entry
    - `:addToQueue 1,4 t` --- Add second and fifth items from current search to the end of the queue
    - `:a 0` --- Add first item from the current search after currently playing entry

## open
Opens a detailed page on the selected item

Open command expects an argument and an optional flag:

- `item` --- **(Argument)** --- The index of an item you want to open

- `-i`, `--in-place` --- **(Flag)** --- Try to open detailed page in-place in the Search Page instead of full detailed page

**Note**: Only playlists could be opened in-place at the moment

## repeatMode
Sets repeat mode of the player.

Repeat mode command has one optional argument:

- `status` --- **(Argument)** --- set specific status:
    - `off`, `false`, `none` - turn repeating off
    - `a`, `all` - set repeat mode to repeat all songs in queue
    - `o`, `one` - set repeat mode to repeat current song

When `status` argument is not passed repeating mode is changed to the next value.

Examples:
    - `:repeat` - Change repeat mode to the next value
    - `:repeatMode all` - Set repeat mode to repeat all songs in queue

## search
Used to make search requests.

Search command expects 1 optional argument, 1 optional option and 1 optional flag:

- `from` --- **(Flag)**
    - `-c`, `--catalog` - search from catalog **(Default)**
    - `-l`, `--library` - search from user library
    - `-r`, `--recent` - request recently played items
    - `-s`, `--recommended` - user recommendations request

- `type` --- **(Option)**
    - `-t`, `--type` - type of searchable item:
        - `so`, `song` - perform search for songs **(Default)**
        - `al`, `album` - perform search for albums
        - `ar`, `artist` - perform search for artists
        - `p`, `pl`, `playlist` - perform search for playlists
        - `st`, `station` - perform search for stations

- `searchPhrase` --- **(Argument)** --- what to search for

**Note**: Search phrase is not needed when requesting recently played items or user recommendations but required when searching for catalog or user library items.

Examples:
    - `:search -c -t so TOOL lateralus` or `:/ TOOL lateralus`--- Search catalog songs for "TOOL lateralus"
    - `:/ -t ar -l TOOL` --- Search for artists "TOOL" in your music library

## setSongTime
Sets playback time for the current entry.

Set song time command expects 1 argument and 1 optional flag:

- `-r`, `--relative` --- **(Flag)** --- This flag is used to treat the argument as relative time to the current playback time **(Default: false)**

- `time` --- **(Argument)** --- This argument can be expressed:
    - either in seconds, e.g. `13`, `-10`, `232`
    - either in "MM:SS" format, e.g. `00:23`, `1:16`
    - or in "HH:MM:SS" format, e.g. `1:42:01`

**Note**: Time argument can be negative only when `-r` flag is passed.

Examples:
    - `:set 00:23` - Set playback to 00:23
    - `:set -r -10` - Set playback 10 seconds earlier

## shuffleMode
Sets shuffling mode of the player.

Shuffle mode command has one optional argument:

- `status` --- **(Argument)** --- set specific status:
    - `false`, `off` - turn shuffling off
    - `true`, `on` - turn shuffling on

When `status` argument is not passed shuffling mode is toggled.

Examples:
    - `:shuffle` - Toggle shuffle mode
    - `:shuffleMode false` - Turn shuffling off

