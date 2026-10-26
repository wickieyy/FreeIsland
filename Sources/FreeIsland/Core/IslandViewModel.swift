import SwiftUI
import Combine

public enum IslandHUD: Equatable {
    case volume(level: Float, isMuted: Bool)
    case brightness(level: Float)
    case battery(percentage: Int, isCharging: Bool)
}

public enum IslandMode: Equatable {
    case idle
    case compactMedia
    case expandedMedia
    case hud(IslandHUD)
}

public final class IslandViewModel: ObservableObject {
    public static let shared = IslandViewModel()

    @Published public private(set) var mode: IslandMode = .idle
    @Published public private(set) var isHovered: Bool = false
    @Published public var isPinned: Bool = false
    @Published public private(set) var currentDimensions: (width: CGFloat, height: CGFloat, cornerRadius: CGFloat) = (180, 32, 14)

    private var activeHUD: IslandHUD?
    private var hudDismissTimer: Timer?
    private var exitHysteresisTimer: Timer?
    private var cancellables = Set<AnyCancellable>()

    public var isExpanded: Bool {
        mode == .expandedMedia
    }

    public init() {
        updateDimensions()
        setupObservers()
    }

    private func setupObservers() {
        // Media changes
        MediaService.shared.$hasActiveMedia
            .receive(on: RunLoop.main)
            .sink { [weak self] hasMedia in
                self?.handleMediaStateChanged(hasMedia)
            }
            .store(in: &cancellables)

        // Volume HUD
        AudioHUDService.shared.onVolumeChanged = { [weak self] volume, isMuted in
            self?.presentHUD(.volume(level: volume, isMuted: isMuted), duration: 1.8)
        }

        // Brightness HUD
        BrightnessHUDService.shared.onBrightnessChanged = { [weak self] brightness in
            self?.presentHUD(.brightness(level: brightness), duration: 1.8)
        }

        // Power / MagSafe HUD
        PowerService.shared.onPluggedIn = { [weak self] power in
            self?.presentHUD(.battery(percentage: power.percentage, isCharging: power.isCharging), duration: 2.8)
        }
    }

    private func handleMediaStateChanged(_ hasMedia: Bool) {
        guard !isHovered, !isPinned, activeHUD == nil else { return }
        withAnimation(.spring(response: 0.36, dampingFraction: 0.74)) {
            self.mode = hasMedia ? .compactMedia : .idle
            self.updateDimensions()
        }
    }

    public func presentHUD(_ hud: IslandHUD, duration: TimeInterval) {
        // Don't interrupt if user is actively interacting with expanded media player
        guard !isHovered, !isPinned else { return }

        hudDismissTimer?.invalidate()
        activeHUD = hud

        withAnimation(.spring(response: 0.36, dampingFraction: 0.74)) {
            self.mode = .hud(hud)
            self.updateDimensions()
        }

        hudDismissTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.activeHUD = nil
            guard !self.isHovered, !self.isPinned else { return }

            withAnimation(.spring(response: 0.36, dampingFraction: 0.74)) {
                self.mode = MediaService.shared.hasActiveMedia ? .compactMedia : .idle
                self.updateDimensions()
            }
        }
    }

    public func onMouseEnter() {
        exitHysteresisTimer?.invalidate()
        exitHysteresisTimer = nil
        isHovered = true

        hudDismissTimer?.invalidate()
        activeHUD = nil

        withAnimation(.spring(response: 0.36, dampingFraction: 0.74)) {
            self.mode = .expandedMedia
            self.updateDimensions()
        }
    }

    public func onMouseExit() {
        guard !isPinned else { return }
        exitHysteresisTimer?.invalidate()
        exitHysteresisTimer = Timer.scheduledTimer(withTimeInterval: 0.35, repeats: false) { [weak self] _ in
            guard let self = self, !self.isPinned else { return }
            self.isHovered = false

            withAnimation(.spring(response: 0.36, dampingFraction: 0.74)) {
                self.mode = MediaService.shared.hasActiveMedia ? .compactMedia : .idle
                self.updateDimensions()
            }
        }
    }

    public func togglePin() {
        isPinned.toggle()
        withAnimation(.spring(response: 0.36, dampingFraction: 0.74)) {
            if isPinned {
                self.mode = .expandedMedia
            } else if !isHovered {
                self.mode = MediaService.shared.hasActiveMedia ? .compactMedia : .idle
            }
            self.updateDimensions()
        }
    }

    public func updateDimensions() {
        let notch = NotchGeometryEngine.shared.currentNotch
        self.currentDimensions = calculateDimensions(for: mode, notch: notch)
    }

    public func calculateDimensions(for mode: IslandMode, notch: NotchInfo) -> (width: CGFloat, height: CGFloat, cornerRadius: CGFloat) {
        let notchH = notch.hasPhysicalNotch ? notch.notchRect.height : 32
        let notchW = notch.hasPhysicalNotch ? notch.notchRect.width : 180

        switch mode {
        case .idle:
            if notch.hasPhysicalNotch {
                return (notchW, notchH, notch.cornerRadius)
            } else {
                return (180, 32, 16)
            }
        case .compactMedia:
            if notch.hasPhysicalNotch {
                // Wings extending 42pt on each side of the physical notch
                return (notchW + 84, notchH + 4, 14)
            } else {
                return (220, 34, 17)
            }
        case .hud:
            if notch.hasPhysicalNotch {
                return (max(notchW + 80, 270), notchH + 38, 18)
            } else {
                return (240, 36, 18)
            }
        case .expandedMedia:
            if notch.hasPhysicalNotch {
                // Height must include notchH so all media content is pushed below the camera
                return (400, notchH + 160, 26)
            } else {
                return (380, 160, 26)
            }
        }
    }
}
