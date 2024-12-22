# Configuration

Yatoro supports deep configuration through the configuration file.

If `XDG_CONFIG_HOME` environment is set, the configuration folder would be `$XDG_CONFIG_HOME/Yatoro`.
Otherwise, `~/.config/Yatoro` will be used instead.

If the directory doesn't exist, Yatoro will create it on startup.

If config file doesn't exist, Yatoro will create it as well.
So you can check the default config for the reference once it's created.

Yatoro supports JSON, YAML and TOML for configuration. So the configuration file could be one of the following:
- `config.json`
- `config.yaml` or `config.yml`
- `config.toml`

Alternatively, the path to config file could be provided with `-c` or `--config` argument.

## ui

- `frameDelay` - **UInt64** --- delay in nanoseconds between UI renders. **Default: 5000000**

### ui.artwork

Yatoro can show artwork for the music item. The quality of this artwork can be changed:

- `width` - **UInt32** --- pixel width of the artwork. **Default: 500**
- `height` - **UInt32** --- pixel height of the artwork. **Default: 500**

### ui.theme

**String** --- the name of the active theme. See [theming](THEMING.md) for creating your own theme. **Default: "default"**

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

`mappings` is an array of `Mapping`s

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

## settings

- `disableSigInt` - **Bool** --- Disable `<CTRL-c>` default behaviour (quitApplication) to use it for remapping
- `disableResize` - **Bool** --- Disable resizing the UI
