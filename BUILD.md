# Build

## Requirements

Make sure you have `notcurses` installed, you can do that with Homebrew:

```
brew install notcurses
```

## Debug version

```
git clone https://github.com/jayadamsmorgan/Yatoro
cd Yatoro
swift build
```

Built executable is located in `.build/debug/yatoro`

## Release version

```
git clone https://github.com/jayadamsmorgan/Yatoro
cd Yatoro
swift build -c release
```

Built executable is located in `.build/release/yatoro`

The release version has to be codesigned in order to be functional. To codesign the app:

- Retreive your Developer ID certificate:

```
security find-identity -p basic -v
```

- Copy UUID of your identity and sign:

```
codesign --sign your_identity_uuid_here -o runtime --timestamp .build/release/yatoro
```

- Verify code signature with:

```
codesign --display --verbose .build/release/yatoro
```

## Building universal executable

This is where the fun begins.

1. The first step is to have a universal `notcurses` library installed:

- Install two versions of Homebrew:

```
arch -x86_64 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

- Install `notcurses` library with both versions:

```
/opt/homebrew/bin/brew install notcurses
/usr/local/bin/brew install notcurses
```

- Create a universal library using `lipo`:

```
lipo -create /opt/homebrew/lib/libnotcurses.dylib /usr/local/lib/libnotcurses.dylib -output libnotcurses.dylib
lipo -create /opt/homebrew/lib/libnotcurses-core.dylib /usr/local/lib/libnotcurses-core.dylib -output libnotcurses-core.dylib
```
- Replace arm64 version of the library with generated universal: (Replace "3.0.11" with your actual version of notcurses)

```
mv libnotcurses.dylib /opt/homebrew/Cellar/notcurses/3.0.11/lib/libnotcurses.3.0.11.dylib
mv libnotcurses-core.dylib /opt/homebrew/Cellar/notcurses/3.0.11/lib/libnotcurses-core.3.0.11.dylib
```

- After that you should delete x86_64 version of notcurses with `/usr/local/bin/brew uninstall notcurses` or uninstall x86_64 Homebrew itself.

2. Build it with Xcode

- Select `Any Mac` target

- Build or archive

