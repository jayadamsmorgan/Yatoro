# Configuration

Yatoro supports deep configuration through the `config.yaml` which should be located in `~/.config/Yatoro`

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
- `songItem` --- see [songItem](#songItem)

#### ui.colors.search

- `page` --- Search page background
- `pageName` --- "Search" string
- `border` --- page border
- `songItem` --- see [songItem](#songItem)

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
- `action` - **String** --- Action to be performed when the key is pressed
- `remap` - **Bool** --- When set to `true` removes the default mapping with the same action. **Default: false**

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

## Default configuration

The default config would look like:

```yaml
ui:
  margins:
    all: 0
    left: null
    right: null
    top: null
    bottom: null
  layout:
    rows: 2
    cols: 2
    pages:
    - nowPlaying
    - queue
    - search
  frameDelay: 5000000
  colors:
    nowPlaying:
      page: {}
      pageName: {}
      border: {}
      slider: {}
      sliderKnob: {}
      controls: {}
      artistLeft: {}
      artistRight: {}
      songLeft: {}
      songRight: {}
      albumLeft: {}
      albumRight: {}
      currentTime: {}
      duration: {}
    commandLine:
      page: {}
      modeNormal: {}
      modeCommand: {}
      playStatus: {}
      time: {}
      input: {}
      nowPlayingArtist: {}
      nowPlayingDash: {}
      nowPlayingTitle: {}
    search:
      page: {}
      pageName: {}
      border: {}
      searchPhrase: {}
      songItem:
        page: {}
        pageName: {}
        border: {}
        artistLeft: {}
        artistRight: {}
        songLeft: {}
        songRight: {}
        albumLeft: {}
        albumRight: {}
    queue:
      page: {}
      pageName: {}
      border: {}
      songItem:
        page: {}
        pageName: {}
        border: {}
        artistLeft: {}
        artistRight: {}
        songLeft: {}
        songRight: {}
        albumLeft: {}
        albumRight: {}
  artwork:
    width: 500
    height: 500
logging:
  logLevel: null
  ncLogLevel: -1
mappings:
- key: p
  action: playPauseToggle
- key: p
  modifiers:
  - alt
  action: play
- key: p
  modifiers:
  - ctrl
  action: pause
- key: c
  action: stop
- key: x
  action: clearQueue
- key: f
  action: playNext
- key: f
  modifiers:
  - ctrl
  action: startSeekingForward
- key: g
  action: stopSeeking
- key: b
  action: playPrevious
- key: b
  modifiers:
  - ctrl
  action: startSeekingBackward
- key: r
  action: restartSong
- key: s
  action: startSearching
- key: ':'
  modifiers:
  - shift
  action: openCommmandLine
- key: s
  modifiers:
  - ctrl
  action: stationFromCurrentEntry
- key: q
  action: quitApplication
```
