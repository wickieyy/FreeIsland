import AppKit
import SwiftUI
import Combine

public final class IslandPanelController: ObservableObject {
    public static let shared = IslandPanelController()

    public private(set) var panel: IslandPanel?
    private var hostingView: NSHostingView<IslandMorphView>?
    private var cancellables = Set<AnyCancellable>()
    private var collapseTimer: Timer?

    public init() {}

    public func setup() {
        let notch = NotchGeometryEngine.shared.currentNotch
        let dims = IslandViewModel.shared.calculateDimensions(notch: notch)
        let initialRect = calculateWindowRect(for: dims, notch: notch)

        let newPanel = IslandPanel(contentRect: initialRect)
        let rootView = IslandMorphView()
        let hosting = NSHostingView(rootView: rootView)
        hosting.frame = NSRect(origin: .zero, size: initialRect.size)
        hosting.autoresizingMask = [.width, .height]

        newPanel.contentView = hosting
        self.panel = newPanel
        self.hostingView = hosting

        updateWindowPosition(animate: false)
        newPanel.orderFrontRegardless()

        observeChanges()
    }

    private func observeChanges() {
        // Observe notch geometry changes
        NotchGeometryEngine.shared.$currentNotch
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateWindowPosition(animate: false)
            }
            .store(in: &cancellables)

        // Observe island state transitions
        IslandViewModel.shared.$state
            .receive(on: RunLoop.main)
            .sink { [weak self] newState in
                self?.handleStateChange(newState)
            }
            .store(in: &cancellables)
    }

    private func handleStateChange(_ newState: IslandState) {
        collapseTimer?.invalidate()
        collapseTimer = nil

        let notch = NotchGeometryEngine.shared.currentNotch
        let dims = IslandViewModel.shared.calculateDimensions(notch: notch)
        let targetRect = calculateWindowRect(for: dims, notch: notch)

        guard let panel = panel else { return }

        if newState == .expanded {
            // Expand window immediately so SwiftUI spring animation isn't clipped
            panel.setFrame(targetRect, display: true, animate: false)
        } else {
            // Wait for SwiftUI spring to complete before shrinking window frame
            collapseTimer = Timer.scheduledTimer(withTimeInterval: 0.38, repeats: false) { [weak self] _ in
                guard let self = self, let panel = self.panel else { return }
                let currentDims = IslandViewModel.shared.calculateDimensions(notch: notch)
                let finalRect = self.calculateWindowRect(for: currentDims, notch: notch)
                panel.setFrame(finalRect, display: true, animate: false)
            }
        }
    }

    public func updateWindowPosition(animate: Bool = false) {
        guard let panel = panel else { return }
        let notch = NotchGeometryEngine.shared.currentNotch
        let dims = IslandViewModel.shared.calculateDimensions(notch: notch)
        let rect = calculateWindowRect(for: dims, notch: notch)
        panel.setFrame(rect, display: true, animate: animate)
    }

    private func calculateWindowRect(for dims: (width: CGFloat, height: CGFloat, cornerRadius: CGFloat), notch: NotchInfo) -> NSRect {
        let screen = notch.screenFrame
        let width = dims.width
        let height = dims.height

        let x: CGFloat
        let y: CGFloat

        if notch.hasPhysicalNotch {
            x = notch.notchRect.midX - (width / 2)
            y = screen.maxY - height
        } else {
            x = screen.midX - (width / 2)
            y = screen.maxY - height - 8
        }

        return NSRect(x: x, y: y, width: width, height: height)
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
