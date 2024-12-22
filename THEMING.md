# Theming

Themes should be located in `"~/.config/Yatoro/themes"` directory.

If this directory doesn't exist Yatoro will create it on startup and put the default one in there.

So you can check the default theming config for the reference once it's created.

`Color` is a string property, which could be represented in theme config file:

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

Each UI element has `bg` and `fg` properties.

- `bg` - **Color** --- the color of the plane on which symbols are rendered. **Default: nil**
- `fg` - **Color** --- the color of symbols on the plane themselves. **Default: nil**

By default, both properties are `nil` on every UI element, which basically means using default terminal background and foreground colors.

## commandLine

- `page` --- Command line background
- `modeNormal` --- normal mode status
- `modeCommand` --- command mode status
- `playStatus` --- status of the player, e.g. playing, paused, stopped, etc.
- `time` --- song playback time and duration
- `input` --- command mode input (or output)
- `nowPlayingArtist` --- artist name string
- `nowPlayingDash` --- "-" between artist name string and song title string
- `nowPlayingTitle` --- song title string
- `completions` --- command line completions
- `completionSelected` --- command line selected completion

## nowPlaying

- `page` --- Now Playing page background
- `pageName` --- "Now Playing" string
- `border` --- page border
- `slider` --- time slider
- `sliderKnob` --- time slider knob
- `controls` --- backward, play/pause, forward icons
- `artistLeft` --- "Artist:" string
- `artistRight` --- artist name string
- `songLeft` --- "Song:" string
- `songRight` ---  song title string
- `albumLeft` --- "Album:" string
- `albumRight` --- album title string
- `currentTime` --- song playback time
- `duration` --- song duration

## queue

- `page` --- Queue page background
- `pageName` --- "Player Queue" string
- `border` --- page border
- `shuffleMode` --- status of repeat mode
- `repeatMode` --- status of repeat mode
- `songItem` --- see [songItem](#songItem)

## search

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

## albumDetail

- `page` --- Album detail page background
- `border` --- page border
- `albumTitle` --- the name of the album
- `artistsText` --- "Artists:" string
- `artistIndices` --- indices of artist items
- `songsText` --- "Songs:" string
- `songIndices` --- indices of song items
- `songItem` --- see [songItem](#songItem)
- `artistItem` --- see [artistItem](#artistItem)

## artistDetail

- `page` --- Artist detail page background
- `border` --- page border
- `artistTitle` --- the name of the artist
- `albumsText` --- "Albums:" string
- `albumIndices` --- indices of album items
- `topSongsText` --- "Top Songs:" string
- `topSongIndices` --- indices of song items
- `songItem` --- see [songItem](#songItem)
- `albumItem` -- see [albumItem](#albumItem)

## playlistDetail

- `page` --- Playlist detail page background
- `border` --- page border
- `playlistTitle` --- the name of the playlist
- `songsText` --- "Songs:" string
- `songIndices` --- indices of song items
- `songItem` --- see [songItem](#songItem)

## recommendationDetail

- `page` --- Recommendation detail page background
- `border` --- page border
- `recommendationTitle` --- the name of the recommendation
- `albumsText` --- "Albums:" string
- `albumIndices` --- indices of album items
- `stationsText` --- "Stations:" string
- `stationIndices` --- indices of station items
- `playlistsText` --- "Playlists:" string
- `playlistIndices` --- indices of playlist items
- `albumItem` --- see [albumItem](#albumItem)
- `stationItem` --- see [stationItem](#stationItem)
- `playlistItem` --- see [playlistItem](#playlistItem)

### songItem

Some pages pages can display song items which could be colored.

- `page` --- song item background
- `border` --- song item border
- `artistLeft` --- "Artist:" string
- `artistRight` --- artist name string
- `songLeft` --- "Song:" string
- `songRight` --- song title string
- `albumLeft` --- "Album:" string
- `albumRight` --- album title string

### albumItem

Similar to [songItem](#songItem), but used when displaying Albums.

- `page` --- album item background
- `border` --- album item border
- `artistLeft` --- "Artist:" string
- `artistRight` --- artist name string
- `albumLeft` --- "Album:" string
- `albumRight` --- album title string
- `genreLeft` --- "Genre:" string
- `genreRight` --- genre names string

### artistItem

Similar to [songItem](#songItem), but used when displaying Artists.

- `page` --- artist item background
- `border` --- artist item border
- `artistLeft` --- "Artist:" string
- `artistRight` --- artist name string
- `genreLeft` --- "Genre:" string
- `genreRight` --- genre names string
- `albumsLeft` --- "Albums:" string
- `albumsRight` --- artist album titles string

### playlistItem

Similar to [songItem](#songItem), but used when displaying Playlists.

- `page` --- playlist item background
- `border` --- playlist item border
- `playlistLeft` --- "Playlist:" string
- `playlistRight` --- playlist name string
- `curatorLeft` --- "Curator:" string
- `curatorRight` --- curator name string
- `descriptionLeft` --- "Description:" string
- `descriptionRight` --- playlist description string

### stationItem

Similar to [songItem](#songItem), but used when displaying Stations.

- `page` --- station item background
- `border` --- station item border
- `stationLeft` --- "Station:" string
- `stationRight` --- station name string
- `isLiveLeft` --- "IsLive:" string
- `isLiveRight` --- is station live boolean string
- `notesLeft` --- "Notes:" string
- `notesRight` --- station editorial notes string

### recommendationItem

Similar to [songItem](#songItem), but used when displaying Recommendations.

- `page` --- recommnedation item background
- `border` --- recommnedation item border
- `titleLeft` --- "Title:" string
- `titleRight` --- recommendation name string
- `refreshDateLeft` --- "Refresh:" string
- `refreshDateRight` --- recommnedation next refresh date string
- `typesLeft` --- "Types:" string
- `typesRight` --- recommendation types string
