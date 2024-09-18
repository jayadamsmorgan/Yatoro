<div align="center">

# Yatoro
**First Apple Music Player in Terminal**

</div>


## Overview

Yatoro is a standalone Apple Music player written in Swift intended to be used in a Terminal emulator.

Yatoro strives for bringing all the features of the Apple Music app into your Terminal.


## Installation

### Requirements

- Active Apple Music subscription
- macOS Sonoma or higher
    - MusicKit library is only available on macOS for now. The workaround for Linux is being actively looked into, if you have any ideas please let me know
- Terminal of your preference

### Steps

- Download pre-built [release][release_page] or build it from source:
    - Clone the repository:
    ```
    git clone https://github.com/jayadamsmorgan/Yatoro.git
    cd Yatoro
    ```
    - Build it:
    ```
    swift build -c release
    ```
    - *Optionally*, install it, or add it to `PATH`:
    ```
    sudo cp .build/release/Yatoro /usr/local/bin/.
    ```

- **Important:** Add both your Terminal and the Yatoro application in `System Settings -> Privacy & Security -> Media & Apple Music`

- Run the app

## Feature status

The player is still very early in the development, so the features are quite limited for now.

| Feature | Status | Comments |
| --------------- | --------------- | --------------- |
| Playing music | Working |  |
| Player controls | Working | |
| Searching music | In Progress |  |
| Player queue | Working | |


## Usage

### Default Controls

| Action                  | Button | Modifier |
|-------------------------|--------|----------|
| Play/Pause              |  `p`   |         |
| Play                    |  `P`   | `SHIFT` |
| Pause                   |  `p`   | `CTRL`  |
| Stop                    |  `c`   | `CTRL`  |
| Clear queue             |  `C`   | `SHIFT` |
| Play next               |  `f`   |         |
| Start seeking forward   |  `F`   | `SHIFT` |
| Play previous           |  `b`   |         |
| Start seeking backward  |  `B`   | `SHIFT` |
| Restart song            |  `r`   |         |
| Start searching         |  `S`   | `SHIFT` |
| Open command line       |  `:`   | `SHIFT` |
| Quit application        |  `q`   |         |

### Configuring

Some of the options might be configured with command line arguments. Check `Yatoro -h`.

Another way to configure everything is to edit `~/.config/Yatoro/config.yaml`. Example configuration:

```yaml
mappings:
  - key: " " # SPACE
    action: playPauseToggle

  - key: "D"
    modifiers:
      - shift
    action: clearQueue

ui:
  margins:
    all: 10
    left: 20
```

#### Default config

```yaml
mappings:
  - key: "p"
    action: playPauseToggle

  - key: "P"
    modifiers:
      - shift
    action: play

  - key: "p"
    modifiers:
      - ctrl
    action: pause

  - key: "c"
    modifiers:
      - ctrl
    action: stop

  - key: "C"
    modifiers:
      - shift
    action: clearQueue

  - key: "f"
    action: playNext

  - key: "F"
    modifiers:
      - shift
    action: startSeekingForward

  - key: "b"
    action: playPrevious

  - key: "B"
    modifiers:
      - shift
    action: startSeekingBackward

  - key: "r"
    action: restartSong

  - key: "S"
    modifiers:
      - shift
    action: startSearching

  - key: ":"
    modifiers:
      - shift
    action: openCommmandLine

  - key: "q"
    action: quitApplication

ui:
  margins:
    all: 0
    left: null
    right: null
    top: null
    bottom: null

logging:
  ncLogLevel: -1
  logLevel: null
```


Command line arguments will overwrite the options set in `config.yaml`


[release_page]: https://github.com/jayadamsmorgan/Yatoro/releases 
