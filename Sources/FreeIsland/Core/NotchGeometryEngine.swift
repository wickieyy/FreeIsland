import AppKit
import Foundation
import Combine

public struct NotchInfo: Equatable {
    public let hasPhysicalNotch: Bool
    public let notchRect: NSRect
    public let screenFrame: NSRect
    public let topInset: CGFloat
    public let cornerRadius: CGFloat

    public var notchCenter: CGPoint {
        CGPoint(x: notchRect.midX, y: notchRect.midY)
    }

    public static let fallback = NotchInfo(
        hasPhysicalNotch: false,
        notchRect: NSRect(x: 0, y: 0, width: 180, height: 32),
        screenFrame: NSRect(x: 0, y: 0, width: 1440, height: 900),
        topInset: 0,
        cornerRadius: 16
    )
}

public final class NotchGeometryEngine: ObservableObject {
    public static let shared = NotchGeometryEngine()

    @Published public private(set) var currentNotch: NotchInfo = .fallback
    @Published public var forceFloatingPillOnNotchless: Bool = true

    private var cancellables = Set<AnyCancellable>()

    public init() {
        updateGeometry()
        observeScreenChanges()
    }

    private func observeScreenChanges() {
        NotificationCenter.default.publisher(for: NSApplication.didChangeScreenParametersNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateGeometry()
            }
            .store(in: &cancellables)
    }

    public func updateGeometry() {
        let screens = NSScreen.screens
        
        // Prefer built-in notch screen, otherwise default to main or first screen
        let targetScreen = screens.first(where: { screen in
            screen.safeAreaInsets.top > 0
        }) ?? NSScreen.main ?? screens.first

        guard let screen = targetScreen else {
            currentNotch = .fallback
            return
        }

        let hasNotch = screen.safeAreaInsets.top > 0
        let screenFrame = screen.frame

        if hasNotch,
           let leftArea = screen.auxiliaryTopLeftArea,
           let rightArea = screen.auxiliaryTopRightArea {
            let notchX = leftArea.maxX
            let notchWidth = max(rightArea.minX - leftArea.maxX, 160)
            let notchHeight = screen.safeAreaInsets.top
            let notchY = screenFrame.maxY - notchHeight

            currentNotch = NotchInfo(
                hasPhysicalNotch: true,
                notchRect: NSRect(x: notchX, y: notchY, width: notchWidth, height: notchHeight),
                screenFrame: screenFrame,
                topInset: notchHeight,
                cornerRadius: 12
            )
        } else {
            // Floating pill for notchless MacBooks or external displays
            let pillWidth: CGFloat = 190
            let pillHeight: CGFloat = 34
            let marginFromTop: CGFloat = 8
            let notchX = screenFrame.midX - (pillWidth / 2)
            let notchY = screenFrame.maxY - pillHeight - marginFromTop

            currentNotch = NotchInfo(
                hasPhysicalNotch: false,
                notchRect: NSRect(x: notchX, y: notchY, width: pillWidth, height: pillHeight),
                screenFrame: screenFrame,
                topInset: 0,
                cornerRadius: 17
            )
        }
    }
}
