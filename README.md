# FreeIsland 🏝️

> A fluid, native macOS menu bar accessory that transforms the MacBook camera notch and external displays into an interactive media hub and system HUD.

[![Platform](https://img.shields.io/badge/macOS-13.0%2B-black?logo=apple)](https://www.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-6.0%20%7C%205.9-orange?logo=swift)](https://swift.org)

---

## ✨ Features

### 🎵 Universal Now Playing Media Hub
- **Notch Wings in Compact Mode**: Flanks your MacBook camera notch with a mini album art thumbnail on the left and an animated audio equalizer pulsing in real time on the right.
- **Fluid Spring Hover Expansion**: Hovering over the notch smoothly expands the full media player card below the camera bezel:
  - High-resolution album artwork with subtle glow
  - Track title & artist with dynamic marquee truncation
  - Interactive scrub bar with live elapsed and remaining time labels
  - Playback controls: Previous, Play / Pause toggle, and Next track
- **Universal Player Support**: Integrates with **Spotify**, **Apple Music**, and web audio (**YouTube**, podcasts, SoundCloud in Safari/Chrome) via native `MediaRemote` and AppleScript bridges.
- **Hover Debounce (Hysteresis)**: A 350ms exit timer prevents accidental collapse when moving the cursor across screen borders.

### 🎯 Hardware Notch Aware
- **Exact Cutout Detection**: Senses your MacBook screen's physical notch dimensions via `NSScreen.safeAreaInsets` and `auxiliaryTopLeftArea`.
- **Zero Bezel Obstruction**: Content dynamically insets below the camera cutout so the plastic bezel never obscures song titles, artists, or album art.
- **External Display Mode**: Automatically switches to a floating pill capsule when running on external monitors or notchless Macs.

### ⚡️ System HUD Replacements
- **MagSafe & Charging HUD**: Connecting your charger instantly pops open a glowing green lightning indicator with real-time battery percentage before smoothly collapsing.
- **Volume HUD**: Replaces the bulky macOS on-screen display with an elegant volume pill featuring dynamic speaker icons (`speaker.slash.fill`, `speaker.wave.1/2/3.fill`), a progress bar, and percentage readout.
- **Brightness HUD**: Adjusting display brightness triggers a subtle sun icon with an animated level slider.

### 🌊 Zero-Jitter Window Architecture
- **Passthrough Overlay**: Uses a stationary, borderless `NSPanel` at `.statusBar` level. Non-island screen areas are transparent and pass clicks straight through to windows or the menu bar underneath.
- **Pure Metal Spring Physics**: No window-resizing lag or coordinate jumping; all shape morphing is powered directly by hardware-accelerated SwiftUI spring curves (`response: 0.36`, `dampingFraction: 0.74`).
- **Resource Efficient**: Pure native Swift/AppKit/SwiftUI with zero third-party dependencies, < 30MB RAM usage, and < 0.2% idle CPU.

---

## 🛠️ Technology Stack

- **UI & Animations**: SwiftUI & AppKit (`NSPanel`, `NSHostingView`)
- **System Audio**: `CoreAudio` (`kAudioHardwareServiceDeviceProperty_VirtualMainVolume`)
- **Power & Battery**: `IOKit.ps` (`IOPSNotificationCreateRunLoopSource`)
- **Media Control**: macOS `MediaRemote.framework` & AppleScript
- **Display Brightness**: `DisplayServices.framework`
- **Build System**: Swift Package Manager (SPM)

---

## 🚀 Building & Running from Source

### Prerequisites
- macOS 13.0 (Ventura) or later
- Apple Silicon or Intel Mac
- Xcode Command Line Tools (`xcode-select --install`)

### Build the App Bundle
Clone the repository and run the build script:

```bash
git clone https://github.com/wickieyy/FreeIsland.git
cd FreeIsland
./scripts/build_app.sh release
```

Launch the application:
```bash
open FreeIsland.app
```

---

## ⌨️ Shortcuts & Menu Bar
FreeIsland runs as an accessory menu bar application (`LSUIElement = true`):
- Click the capsule icon (`􀟥`) in the top menu bar for options.
- **`⌘E`**: Expand or collapse the island manually
- **`⌘P`**: Pin the media player to keep it open
- **`⌘R`**: Force refresh media status
- **`⌘Q`**: Quit FreeIsland
