import AppKit
import Foundation
import Combine

public struct MediaItem: Equatable {
    public var title: String
    public var artist: String
    public var album: String
    public var isPlaying: Bool
    public var position: Double
    public var duration: Double
    public var artwork: NSImage?
    public var sourceApp: String

    public static let empty = MediaItem(
        title: "",
        artist: "",
        album: "",
        isPlaying: false,
        position: 0,
        duration: 0,
        artwork: nil,
        sourceApp: ""
    )

    public var progress: Double {
        guard duration > 0 else { return 0 }
        return min(max(position / duration, 0), 1.0)
    }

    public var formattedPosition: String {
        formatTime(position)
    }

    public var formattedDuration: String {
        formatTime(duration)
    }

    private func formatTime(_ time: Double) -> String {
        guard !time.isNaN && !time.isInfinite && time >= 0 else { return "0:00" }
        let totalSeconds = Int(time)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    public static func == (lhs: MediaItem, rhs: MediaItem) -> Bool {
        return lhs.title == rhs.title &&
            lhs.artist == rhs.artist &&
            lhs.album == rhs.album &&
            lhs.isPlaying == rhs.isPlaying &&
            abs(lhs.position - rhs.position) < 1.0 &&
            abs(lhs.duration - rhs.duration) < 1.0 &&
            lhs.sourceApp == rhs.sourceApp
    }
}

public final class MediaService: ObservableObject {
    public static let shared = MediaService()

    @Published public private(set) var currentTrack: MediaItem = .empty
    @Published public private(set) var hasActiveMedia: Bool = false

    private var pollTimer: Timer?
    private var interpolationTimer: Timer?
    private var lastFetchTime = Date()

    private let remoteBridge = MediaRemoteBridge.shared
    private let scriptBridge = AppleScriptMediaBridge.shared

    public init() {
        startObserving()
    }

    public func startObserving() {
        // Poll every 1.5 seconds for external track changes
        pollTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { [weak self] _ in
            self?.refreshMedia()
        }

        // Interpolate progress smoothly every 0.25 seconds when track is playing
        interpolationTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
            self?.interpolatePlaybackProgress()
        }

        // Listen for workspace notifications (app launches, activations)
        NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.refreshMedia()
        }

        refreshMedia()
    }

    public func refreshMedia() {
        // Try Universal MediaRemote first
        if remoteBridge.isAvailable {
            remoteBridge.fetchNowPlayingInfo { [weak self] item in
                guard let self = self else { return }
                if let item = item, !item.title.isEmpty {
                    self.updateTrack(item)
                    return
                }
                // Fall back to AppleScript for Music / Spotify
                self.fallbackToAppleScript()
            }
        } else {
            fallbackToAppleScript()
        }
    }

    private func fallbackToAppleScript() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let item = self?.scriptBridge.fetchTrackInfo()
            DispatchQueue.main.async {
                if let item = item {
                    self?.updateTrack(item)
                } else {
                    self?.clearTrackIfInactive()
                }
            }
        }
    }

    private func updateTrack(_ newItem: MediaItem) {
        lastFetchTime = Date()
        var updated = newItem
        // Preserve artwork if new item has none but titles match
        if updated.artwork == nil && currentTrack.artwork != nil && updated.title == currentTrack.title {
            updated.artwork = currentTrack.artwork
        }

        self.currentTrack = updated
        self.hasActiveMedia = !updated.title.isEmpty
    }

    private func clearTrackIfInactive() {
        if hasActiveMedia {
            self.currentTrack = .empty
            self.hasActiveMedia = false
        }
    }

    private func interpolatePlaybackProgress() {
        guard currentTrack.isPlaying, currentTrack.duration > 0 else { return }
        let now = Date()
        let elapsedSinceLastFetch = now.timeIntervalSince(lastFetchTime)
        let projectedPosition = currentTrack.position + elapsedSinceLastFetch
        if projectedPosition <= currentTrack.duration {
            currentTrack.position = projectedPosition
            lastFetchTime = now
        }
    }

    public func togglePlayPause() {
        currentTrack.isPlaying.toggle()
        if !remoteBridge.togglePlayPause() {
            scriptBridge.togglePlayPause()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.refreshMedia()
        }
    }

    public func nextTrack() {
        if !remoteBridge.nextTrack() {
            scriptBridge.nextTrack()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            self?.refreshMedia()
        }
    }

    public func previousTrack() {
        if !remoteBridge.previousTrack() {
            scriptBridge.previousTrack()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            self?.refreshMedia()
        }
    }

    public func seek(to progress: Double) {
        let targetSeconds = progress * currentTrack.duration
        currentTrack.position = targetSeconds
        scriptBridge.seek(to: targetSeconds)
    }
}
