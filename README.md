<div align="center">

# Yatoro
**First Apple Music Player in Terminal**

</div>


## Overview

Yatoro is a standalone Apple Music player written in Swift intended to be used in a Terminal emulator.

Yatoro strives for bringing all the features of the Apple Music app into your Terminal.


## Installation

#### Requirements

- Active Apple Music subscription
- macOS Sonoma or higher
    - MusicKit library is only available on macOS for now. The workaround for Linux is being actively looked into, if you have any ideas please let me know
- Terminal of your preference

#### Steps

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


- Check `Yatoro -h` or `Yatoro --help` for more startup options

[release_page]: https://github.com/jayadamsmorgan/Yatoro/releases 
