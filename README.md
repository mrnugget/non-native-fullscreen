# non-native-fullscreen

This is an experiment, trying to get "non-native fullscreen" working in
Swift/SwiftUI macOS app.

What's non-native fullscreen in macOS? It's a fullscreen mode that is very fast
and allows the fullscreen app to stay in background. Multiple apps use it:

- Kitty calls it ["traditional fullscreen"](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.macos_traditional_fullscreen)
- `mpv` calls it non-native fullscreen: [some codehere](https://github.com/mpv-player/mpv/pull/8596/files)
- `iina` calls it "legacy" fullscreen: [code here](https://github.com/iina/iina/blob/fc66b27d50d0e98b056205867055f462e87828c9/iina/MainWindowController.swift#L1401-L1423)
- MacVim calls it non-native fullscreen: [code here](https://sourcegraph.com/github.com/macvim-dev/macvim@a27b466e4da2173160ed161ef9e307d0806769d3/-/blob/src/MacVim/MMWindowController.m?L959-992)
- wezterm also calls it non-native fullscreen. [docs here](https://wezfurlong.org/wezterm/config/lua/config/native_macos_fullscreen_mode.html), [code here](https://github.com/wez/wezterm/blob/69bb69b9ca30edb82e134a5835fcefadf8830fcc/window/src/os/macos/window.rs#L978)

## The Problem

I can't get it to work so that the window in non-native fullscreen mode has

- no rounded corners. they're tiny, but they're visible
- that the window covers the place where the notch is on a MacBook
![screenshot_2023-07-05_20 30 35@2x](https://github.com/mrnugget/non-native-fullscreen/assets/1185253/69422a10-64e7-4b44-b332-885c70c1aef5)

But _technically_ I'm doing what all the others are doing:

- do `window.styleMask.insert(.borderless)`
- set `window.frame` to the frame of the whole screen
- remove buttons etc.

## Try it

Open `testing.xcodeproj` in Xcode, hit `Cmd+r` for it to run, click button to
toggle fullscreen.
