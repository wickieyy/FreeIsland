import AppKit
import SwiftUI
import Combine

public final class IslandPanelController: ObservableObject {
    public static let shared = IslandPanelController()

    public private(set) var panel: IslandPanel?
    private var hostingView: IslandPassthroughHostingView<IslandMorphView>?
    private var cancellables = Set<AnyCancellable>()

    // Fixed generous frame dimensions for zero-jitter rendering
    private let overlayWidth: CGFloat = 460
    private let overlayHeight: CGFloat = 280

    public init() {}

    public func setup() {
        let notch = NotchGeometryEngine.shared.currentNotch
        let frameRect = calculateFixedWindowRect(notch: notch)

        let newPanel = IslandPanel(contentRect: frameRect)
        let rootView = IslandMorphView()
        let hosting = IslandPassthroughHostingView(rootView: rootView)
        hosting.frame = NSRect(origin: .zero, size: frameRect.size)
        hosting.autoresizingMask = [.width, .height]

        newPanel.contentView = hosting
        self.panel = newPanel
        self.hostingView = hosting

        updateWindowPosition()
        newPanel.orderFrontRegardless()

        observeChanges()
    }

    private func observeChanges() {
        // Observe screen / resolution changes
        NotchGeometryEngine.shared.$currentNotch
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateWindowPosition()
                IslandViewModel.shared.updateDimensions()
            }
            .store(in: &cancellables)
    }

    public func updateWindowPosition() {
        guard let panel = panel else { return }
        let notch = NotchGeometryEngine.shared.currentNotch
        let rect = calculateFixedWindowRect(notch: notch)
        panel.setFrame(rect, display: true, animate: false)
    }

    private func calculateFixedWindowRect(notch: NotchInfo) -> NSRect {
        let screen = notch.screenFrame
        let x: CGFloat
        let y: CGFloat

        if notch.hasPhysicalNotch {
            x = notch.notchRect.midX - (overlayWidth / 2)
            y = screen.maxY - overlayHeight
        } else {
            x = screen.midX - (overlayWidth / 2)
            y = screen.maxY - overlayHeight - 8
        }

        return NSRect(x: x, y: y, width: overlayWidth, height: overlayHeight)
    }

    public func toggleVisibility() {
        guard let panel = panel else { return }
        if panel.isVisible {
            panel.orderOut(nil)
        } else {
            panel.orderFrontRegardless()
        }
    }
}
