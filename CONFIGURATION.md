# Configuration

Yatoro supports deep configuration through the `config.yaml` which should be located in `~/.config/Yatoro`

See [example config](example_config.yaml)

## ui

- `frameDelay` - **UInt64** --- delay in nanoseconds between UI renders. **Default: 5000000**

### ui.artwork

Yatoro can show artwork for the music item. The quality of this artwork can be changed:

- `width` - **UInt32** --- pixel width of the artwork. **Default: 500**
- `height` - **UInt32** --- pixel height of the artwork. **Default: 500**

### ui.colors

**Note**: This is subject to change and will be updated with more pages and elements.

#### Color

`Color` is a string property, which could be represented in config file:

- either as a string of RGB hex in format `#rrggbb`, example: `#bd93f9`
- or as one of the 16 default colors, which are used by your terminal

<details>
  <summary>Default terminal color names</summary>

- `black`
- `red`
- `green`
- `yellow`
- `blue`
- `magenta`
- `cyan`
- `white`
- `brightBlack`
- `brightRed`
- `brightGreen`
- `brightYellow`
- `brightBlue`
- `brightMagenta`
- `brightCyan`
- `brightWhite`

</details>

#### Color pairs

Each UI element has `bg` and `fg` properties.

- `bg` - **Color** --- the color of the plane on which symbols are rendered. **Default: nil**
- `fg` - **Color** --- the color of symbols on the plane themselves. **Default: nil**

By default, both properties are `nil` on every UI element, which basically means using default terminal background and foreground colors.

#### ui.colors.commandLine

- `page` --- Command line background
- `modeNormal` --- normal mode status
- `modeCommand` --- command mode status
- `playStatus` --- status of the player, e.g. playing, paused, stopped, etc.
- `time` --- song playback time and duration
- `input` --- command mode input (or output)
- `nowPlayingArtist` --- artist name string
- `nowPlayingDash` --- "-" between artist name string and song title string
- `nowPlayingTitle` --- song title string

#### ui.colors.nowPlaying

- `page` --- Now Playing page background
- `pageName` --- "Now Playing" string
- `border` --- page border
- `slider` --- time slider
- `sliderKnob` --- time slider knob
- `controls` --- backward, play/pause, forward icons
- `artistLeft` --- "artist:" string
- `artistRight` --- artist name string
- `songLeft` --- "song:" string
- `songRight` ---  song title string
- `albumLeft` --- "album:" string
- `albumRight` --- album title string
- `currentTime` --- song playback time
- `duration` --- song duration

#### ui.colors.queue

- `page` --- Queue page background
- `pageName` --- "Player Queue" string
- `border` --- page border
- `shuffleMode` --- status of repeat mode
- `repeatMode` --- status of repeat mode
- `songItem` --- see [songItem](#songItem)

#### ui.colors.search

- `page` --- Search page background
- `pageName` --- "Search" string
- `border` --- page border
- `itemIndices` --- indices of items in Search page
- `songItem` --- see [songItem](#songItem)
- `albumItem` --- see [albumItem](#albumItem)
- `artistItem` --- see [artistItem](#artistItem)
- `playlistItem` --- see [playlistItem](#playlistItem)
- `stationItem` --- see [stationItem](#stationItem)
- `recommendationItem` --- see [recommendationItem](#recommendationItem)

#### songItem

List pages such as Queue and Search pages can display song items which could be colored.

- `page` --- song item background
- `border` --- song item border
- `artistLeft` --- "artist:" string
- `artistRight` --- artist name string
- `songLeft` --- "song:" string
- `songRight` --- song title string
- `albumLeft` --- "album:" string
- `albumRight` --- album title string

#### albumItem

Similar to [songItem](#songItem), but used only in Search page when displaying Albums.

- `page` --- album item background
- `border` --- album item border
- `artistLeft` --- "artist:" string
- `artistRight` --- artist name string
- `albumLeft` --- "album:" string
- `albumRight` --- album title string
- `genreLeft` --- "genre:" string
- `genreRight` --- genre names string

#### artistItem

Similar to [songItem](#songItem), but used only in Search page when displaying Artists.

- `page` --- artist item background
- `border` --- artist item border
- `artistLeft` --- "artist:" string
- `artistRight` --- artist name string
- `genreLeft` --- "genre:" string
- `genreRight` --- genre names string
- `albumsLeft` --- "albums:" string
- `albumsRight` --- artist album titles string

#### playlistItem

Similar to [songItem](#songItem), but used only in Search page when displaying Playlists.

- `page` --- playlist item background
- `border` --- playlist item border
- `playlistLeft` --- "playlist:" string
- `playlistRight` --- playlist name string
- `curatorLeft` --- "curator:" string
- `curatorRight` --- curator name string
- `descriptionLeft` --- "description:" string
- `descriptionRight` --- playlist description string

#### playlistItem

Similar to [songItem](#songItem), but used only in Search page when displaying Stations.

- `page` --- station item background
- `border` --- station item border
- `stationLeft` --- "station:" string
- `stationRight` --- station name string
- `isLiveLeft` --- "isLive:" string
- `isLiveRight` --- is station live boolean string
- `notesLeft` --- "notes:" string
- `notesRight` --- station editorial notes string

#### recommendationItem

Similar to [songItem](#songItem), but used only in Search page when displaying Stations.

- `page` --- recommnedation item background
- `border` --- recommnedation item border
- `titleLeft` --- "title:" string
- `titleRight` --- recommendation name string
- `refreshDateLeft` --- "refresh:" string
- `refreshDateRight` --- recommnedation next refresh date string
- `typesLeft` --- "types:" string
- `typesRight` --- recommendation types string

### ui.layout

- `rows` - **UInt32** --- amount of UI "rows". **Default: 2**
- `cols` - **UInt32** --- amount of UI "cols". **Default: 2**
- `pages` - **Array\<String\>** - visible pages and their order in the Yatoro UI
    - **Values**: `nowPlaying`, `queue`, `search`
    - **Default**: [ `nowPlaying`, `queue`, `search` ]

### ui.margins

- `all` - **UInt32** --- margins for all directions between the UI and terminal. **Default: 0**
- `left` - **UInt32** --- margin for left side between the UI and terminal. **Default: nil**
- `right` - **UInt32** --- margin for right side between the UI and terminal. **Default: nil**
- `top` - **UInt32** --- margin for top side between the UI and terminal. **Default: nil**
- `bottom` - **UInt32** --- margin for bottom side between the UI and terminal. **Default: nil**

## logging

If the logLevel property is set to non-nil value, the `yatoro.log` file will be created in the current working directory.

- `logLevel` - **String** --- logging level of Yatoro used for `yatoro.log` file. If nil, no logging is used
    - **Values**: nil, `critical`, `error`, `info`, `warning`, `debug`, `trace`
    - **Default**: nil
- `ncLogLevel` - **String** --- logging level of notcurses library which is used for UI drawing
    - **Values**: -1, 0, 1, 2, 3
    - **Default**: -1

## mappings

`ui.mappings` is an array of `Mapping`s

Each `Mapping` has 3 properties:

- `key` - **String** --- UTF-8 representation of the pressed key
- `modifiers` - **Array\<String\>** --- Modifiers for the key
- `action` - **String** --- Action to be performed when the key is pressed. See [mappings.action](#mappings.action)
- `remap` - **Bool** --- When set to `true` removes the default mapping with the same key and modifiers. **Default: false**

You can check the default mappings down below in the default configuration.

Available modifiers:
- `shift`
- `ctrl`
- `alt`
- `meta`
- `super`
- `hyper`
- `capslock`
- `numlock`

**Note**: On some terminals only `shift` and `ctrl` modifiers are working. This is due to the bug in notcurses library.

### mappings.action

Action is a String which will be executed when mapping is activated.

It will be executed character by character so you can execute not only [commands](#COMMANDS.md) but also other mappings.

It also has syntax for modifiers and special keys. Examples:
    - `<CR>` - press `return` (`enter`) key
    - `<CTRL-g>` - press `g` with modifier `CTRL`. See available modifiers in [mappings](#mappings)
    - `<CTRL-ALT-h>` - press `h` with modifiers `CTRL` and `ALT`
    - `<SPACE>`
    - `<ESC>`
    - `<TAB>`

Some examples:

- `:playPauseToggle<CR>` - Execute `playPauseToggle` command
- `<CTRL-f>e` - Execute mapping with key `f` and modifier `CTRL`, then execute mapping with key `e`
- `:search ` - Open command line and type `search `
- `:shuffleMode<CR><SHIFT-e>` - Execute `shuffleMode` command, then execute mapping with key `e` and modifier `SHIFT`

See [COMMANDS.md](#COMMANDS.md) for all available commands

