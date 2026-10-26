import AppKit
import SwiftUI

public final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?

    public func applicationDidFinishLaunching(_ notification: Notification) {
        // Prevent app from quitting when windows close
        NSApp.setActivationPolicy(.accessory)

        // Initialize Notch and Island Panel
        NotchGeometryEngine.shared.updateGeometry()
        IslandPanelController.shared.setup()

        // Initialize Media Remote tracking
        MediaService.shared.startObserving()

        // Setup Menu Bar Extra
        setupStatusItem()
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            let image = NSImage(systemSymbolName: "capsule.inset.filled", accessibilityDescription: "FreeIsland")
            button.image = image
            button.imagePosition = .imageOnly
        }

        buildMenu()
    }

    private func buildMenu() {
        let menu = NSMenu()

        let headerItem = NSMenuItem(title: "FreeIsland — Dynamic Notch", action: nil, keyEquivalent: "")
        headerItem.isEnabled = false
        menu.addItem(headerItem)

        let statusText = NotchGeometryEngine.shared.currentNotch.hasPhysicalNotch ? "Mode: Hardware Notch" : "Mode: Floating Capsule"
        let modeItem = NSMenuItem(title: statusText, action: nil, keyEquivalent: "")
        modeItem.isEnabled = false
        menu.addItem(modeItem)

        menu.addItem(NSMenuItem.separator())

        let toggleExpandItem = NSMenuItem(
            title: "Expand / Collapse Island",
            action: #selector(toggleIslandExpansion),
            keyEquivalent: "e"
        )
        toggleExpandItem.target = self
        menu.addItem(toggleExpandItem)

        let togglePinItem = NSMenuItem(
            title: "Pin / Keep Expanded",
            action: #selector(togglePin),
            keyEquivalent: "p"
        )
        togglePinItem.target = self
        menu.addItem(togglePinItem)

        let refreshMediaItem = NSMenuItem(
            title: "Refresh Media Info",
            action: #selector(refreshMedia),
            keyEquivalent: "r"
        )
        refreshMediaItem.target = self
        menu.addItem(refreshMediaItem)

        menu.addItem(NSMenuItem.separator())

        let openGitHubItem = NSMenuItem(
            title: "GitHub Repository & Docs...",
            action: #selector(openGitHub),
            keyEquivalent: ""
        )
        openGitHubItem.target = self
        menu.addItem(openGitHubItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(
            title: "Quit FreeIsland",
            action: #selector(quitApp),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem?.menu = menu
    }

    @objc private func toggleIslandExpansion() {
        let vm = IslandViewModel.shared
        withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
            if vm.state == .expanded {
                vm.state = MediaService.shared.hasActiveMedia ? .compact : .idle
            } else {
                vm.state = .expanded
            }
        }
    }

    @objc private func togglePin() {
        IslandViewModel.shared.togglePin()
    }

    @objc private func refreshMedia() {
        MediaService.shared.refreshMedia()
    }

    @objc private func openGitHub() {
        if let url = URL(string: "https://github.com/freeisland/freeisland") {
            NSWorkspace.shared.open(url)
        }
    }

    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
