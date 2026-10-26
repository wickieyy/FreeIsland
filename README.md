# FreeIsland 🏝️

> **The 100% Free & Open-Source Dynamic Island for macOS.**  
> Transform your MacBook camera notch (or external monitor) into a fluid, interactive media player and productivity hub.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/macOS-13.0%2B-black?logo=apple)](https://www.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-6.0%20%7C%205.9-orange?logo=swift)](https://swift.org)

---

## ✨ Features

- 🎯 **Native Notch Integration**: Automatically senses the physical camera notch dimensions on Apple Silicon MacBooks (M1/M2/M3/M4 Pro/Max/Air) using AppKit display metrics (`auxiliaryTopLeftArea` & `safeAreaInsets`).
- 🖥️ **External Display & Notchless Support**: Seamlessly displays a floating capsule on external monitors or older MacBooks so you never miss out.
- 🎵 **Now Playing Media Hub**:
  - Automatically captures track metadata, artist, album, and high-res album artwork.
  - Universal media compatibility via `MediaRemote.framework` (Spotify, Apple Music, Safari, Chrome, YouTube, Podcasts, VLC).
  - AppleScript bridge for native Spotify and Apple Music integration.
  - Interactive playback scrubber and controls (Previous, Play/Pause, Next).
- 🌊 **Fluid Spring Physics**: Apple-grade spring physics (`response: 0.35`, `dampingFraction: 0.72`) morphing between idle, compact, and expanded cards.
- ⏱️ **Hover Hysteresis**: Smart 350ms exit debounce timer prevents annoying accidental dismissals when grazing the notch area.
- 🪶 **Ultra-Lightweight**: Built purely with Swift and SwiftUI + AppKit. Zero heavy third-party dependencies, < 30MB RAM, < 0.2% idle CPU.
- 🎛️ **Menu Bar Extra**: Discrete menu bar icon to expand/collapse, pin open, refresh media, or configure settings.

---

## 🚀 Quick Start & Building from Source

### Prerequisites
- macOS 13.0 (Ventura) or later
- Swift 5.9+ / Xcode Command Line Tools (`xcode-select --install`)

### Build & Package App

Clone the repository:
```bash
git clone https://github.com/freeisland/freeisland.git
cd freeisland
```

Build and generate `FreeIsland.app`:
```bash
./scripts/build_app.sh release
```

Launch the app:
```bash
open FreeIsland.app
```

---

## 📐 Architecture & Project Structure

```
FreeIsland/
├── Package.swift                    # Swift Package definition (macOS 13+)
├── scripts/
│   └── build_app.sh                 # Compiles and packages FreeIsland.app
├── Resources/
│   └── Info.plist                   # App metadata (LSUIElement = true)
├── Sources/FreeIsland/
│   ├── main.swift                   # Entry point
│   ├── App/
│   │   └── AppDelegate.swift        # NSApplicationDelegate & Menu Bar Extra
│   ├── Core/
│   │   ├── NotchGeometryEngine.swift# Hardware notch & screen coordinate detector
│   │   ├── IslandPanel.swift        # Non-activating, borderless NSPanel overlay
│   │   ├── IslandPanelController.swift # Window frame sync & screen transitions
│   │   └── IslandViewModel.swift    # Morphing states (idle, compact, expanded)
│   ├── Services/
│   │   ├── MediaService.swift       # Now Playing coordinator & progress interpolator
│   │   ├── MediaRemoteBridge.swift  # Universal MediaRemote framework loader
│   │   └── AppleScriptMediaBridge.swift # Music & Spotify AppleScript handler
│   └── UI/
│       ├── IslandMorphView.swift    # Root SwiftUI morphing shape & hover engine
│       ├── Views/
│       │   ├── CompactMediaView.swift # Wings hugging notch (mini art + visualizer)
│       │   └── ExpandedMediaView.swift# Expanded media card with controls
│       └── Components/
│           ├── AudioVisualizerView.swift # Animated pulsing waveform bars
│           ├── FluidSlider.swift        # Interactive draggable scrub slider
│           └── MarqueeText.swift        # Dynamic title truncation
```

---

## 🗺️ Roadmap

- [x] **Phase 1: MVP Core**
  - [x] Hardware notch detection and screen change observer
  - [x] Borderless floating `NSPanel` overlay
  - [x] SwiftUI morphing container with hover expansion & hysteresis
  - [x] Spotify, Apple Music & Universal MediaRemote playback controls
  - [x] Discrete menu bar status item
- [x] **Phase 2: System HUDs & Animation Architecture Fix**
  - [x] Zero-jitter fixed overlay architecture with custom passthrough hit-testing
  - [x] Modern replacement for macOS Volume HUD (CoreAudio integration)
  - [x] Display Brightness HUD (DisplayServices private API integration)
  - [x] MagSafe charger connection popup & battery percentage (IOKit integration)
- [ ] **Phase 3: Productivity Utilities**
  - [ ] "Notch Drop": Drag-and-drop file shelf and quick AirDrop target
  - [ ] Live countdown timer / Pomodoro pill
- [ ] **Phase 4: Community & Distribution**
  - [ ] Sparkle 2 auto-update framework
  - [ ] Homebrew Cask: `brew install --cask freeisland`
  - [ ] GitHub Actions automated release pipeline

---

## 🤝 Contributing

FreeIsland is 100% free and open-source under the [MIT License](LICENSE). Contributions, bug reports, and feature pull requests are welcome!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

Distributed under the MIT License. See [`LICENSE`](LICENSE) for more information.
