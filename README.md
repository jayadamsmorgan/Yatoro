<div align="center">

# Yatoro
**First Apple Music Player in Terminal**

</div>


## Overview

Yatoro is a standalone VIM-like Apple Music player written in Swift intended to be used in a Terminal emulator.

Yatoro strives for bringing all the features of the Apple Music app into your Terminal.

![](yatoro.gif)


## Installation

### Requirements

- Active Apple Music subscription
- macOS Sonoma or higher
    - MusicKit library is only available on macOS for now. The workaround for Linux is being actively looked into, if you have any ideas please let me know
- Terminal of your preference

### [Homebrew][homebrew]

```
brew tap jayadamsmorgan/yatoro
brew install yatoro
```

### Installer

- Install notcurses library with [Homebrew][homebrew]:

```
brew install notcurses
```

- [Download latest pkg][release_page] and install it.

The installer will put the executable in `/usr/local/bin/yatoro`

### Build from source

Check out [build instructions](BUILD.md).

### Note

- **Important:** Add both your Terminal and the Yatoro application in `System Settings -> Privacy & Security -> Media & Apple Music`

- Run the app

## Feature status

The player is still early in the development, so the features are quite limited for now.


| Feature             | Status  | Comments                                        |
| ------------------- | ------- | ----------------------------------------------- |
| Playing music       | Working |                                                 |
| Player controls     | Working |                                                 |
| Now playing artwork | Working |                                                 |
| Status line         | Working |                                                 |
| Command line        | Working |                                                 |
| Searching music     | Working | Only with `:search` command                     |
| Player queue        | Working | Only adding to queue with `:addToQueue` command |
| Coloring the UI     | Working | Check [THEMING](THEMING.md)                     |
| Mouse controls      |   TBD   |                                                 |
| Arrow navigation    |   TBD   |                                                 |

Feel free to suggest new features through issues!


## Usage

### Configuring

Some of the options might be configured with command line arguments. Check `Yatoro -h`.

Another way to configure everything is configuration file. Check [CONFIGURATION](CONFIGURATION.md).

Command line arguments will overwrite the options set in configuration file.

### Default Controls

| Action                                  | Modifier | Button |
|-----------------------------------------| -------- | ------ |
| Play/Pause Toggle                       |          |  `p`   |
| Play                                    |  `SHIFT` |  `p`   |
| Pause                                   |  `CTRL`  |  `p`   |
| Stop                                    |          |  `c`   |
| Clear queue                             |          |  `x`   |
| Close last search result or detail page |          | `ESC`  |
| Play next                               |          |  `f`   |
| Play previous                           |          |  `b`   |
| Start seeking forward                   |  `CTRL`  |  `f`   |
| Start seeking backward                  |  `CTRL`  |  `b`   |
| Stop seeking                            |          |  `g`   |
| Restart song                            |          |  `r`   |
| Start searching                         |          |  `s`   |
| Station from current entry              |  `CTRL`  |  `s`   |
| Open command line                       |  `SHIFT` |  `:`   |
| Quit application                        |          |  `q`   |
| Quit application (2)                    |  `CTRL`  |  `c`   |

### Commands

Yatoro has a VIM-like command line. Check full command description in [COMMANDS](COMMANDS.md).


## Contributing

Check [CONTRIBUTING](CONTRIBUTING.md) and [CODE_OF_CONDUCT](CODE_OF_CONDUCT.md).


[homebrew]: https://brew.sh
[release_page]: https://github.com/jayadamsmorgan/Yatoro/releases 
[release_issue]: https://github.com/jayadamsmorgan/Yatoro/issues/3
