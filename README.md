<div align="center">

# Yatoro
**First Apple Music Player in Terminal**

</div>


## Overview

Yatoro is a standalone VIM-like Apple Music player written in Swift intended to be used in a Terminal emulator.

Yatoro strives for bringing all the features of the Apple Music app into your Terminal.


## Installation

### Requirements

- Active Apple Music subscription
- macOS Sonoma or higher
    - MusicKit library is only available on macOS for now. The workaround for Linux is being actively looked into, if you have any ideas please let me know
- Terminal of your preference

### Pre-built binary

- [Download pre-built release][release_page]

- Add Yatoro to `PATH` or install it:

```
sudo mv yatoro /usr/local/bin/.
```

### Build from source

[Build from source](BUILD.md)

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
| Coloring the UI     |   WIP   | Only Now Playing page and Command line          |
| Mouse controls      |   TBD   |                                                 |
| Arrow navigation    |   TBD   |                                                 |

Feel free to suggest new features through issues!


## Usage

### Configuring

Some of the options might be configured with command line arguments. Check `Yatoro -h`.

Another way to configure everything is to edit `~/.config/Yatoro/config.yaml`. Check [CONFIGURATION](CONFIGURATION.md).

Command line arguments will overwrite the options set in `config.yaml`

### Default Controls

| Action                     | Modifier | Button |
|----------------------------| -------- | ------ |
| Play/Pause Toggle          |          |  `p`   |
| Play                       |  `SHIFT` |  `p`   |
| Pause                      |  `CTRL`  |  `p`   |
| Stop                       |          |  `c`   |
| Clear queue                |          |  `x`   |
| Play next                  |          |  `f`   |
| Play previous              |          |  `b`   |
| Start seeking forward      |  `CTRL`  |  `f`   |
| Start seeking backward     |  `CTRL`  |  `b`   |
| Stop seeking               |          |  `g`   |
| Restart song               |          |  `r`   |
| Start searching            |          |  `s`   |
| Station from current entry |  `CTRL`  |  `s`   |
| Open command line          |  `SHIFT` |  `:`   |
| Quit application           |          |  `q`   |
| Quit application (2)       |  `CTRL`  |  `c`   |

### Commands

Yatoro has a VIM-like command line. Check full command description in [COMMANDS](COMMANDS.md).


### Contributing

Check [CONTRIBUTING](CONTRIBUTING.md) and [CODE_OF_CONDUCT](CODE_OF_CONDUCT.md).


[release_page]: https://github.com/jayadamsmorgan/Yatoro/releases 
[release_issue]: https://github.com/jayadamsmorgan/Yatoro/issues/3
