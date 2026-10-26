import AppKit
import SwiftUI

public final class IslandPassthroughHostingView<Content: View>: NSHostingView<Content> {
    public override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        return true
    }

    public override func hitTest(_ point: NSPoint) -> NSView? {
        let currentDims = IslandViewModel.shared.currentDimensions
        let islandX = (bounds.width - currentDims.width) / 2
        let islandY = bounds.height - currentDims.height
        let activeRect = NSRect(x: islandX, y: islandY, width: currentDims.width, height: currentDims.height)

        let comfortableHitRect = activeRect.insetBy(dx: -4, dy: -4)
        if comfortableHitRect.contains(point) {
            return super.hitTest(point)
        }
        return nil
    }
}

public final class IslandPanel: NSPanel {
    public init(contentRect: NSRect) {
        super.init(
            contentRect: contentRect,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        self.isOpaque = false
        self.backgroundColor = .clear
        self.hasShadow = false
        self.level = .statusBar
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
        self.isMovable = false
        self.isReleasedWhenClosed = false
        self.acceptsMouseMovedEvents = true
        self.hidesOnDeactivate = false
    }

    public override var canBecomeKey: Bool {
        return false
    }

    public override var canBecomeMain: Bool {
        return false
    }
}
