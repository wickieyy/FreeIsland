import AppKit
import Foundation

public final class MediaRemoteBridge {
    public static let shared = MediaRemoteBridge()

    private typealias MRRegisterFunc = @convention(c) (DispatchQueue) -> Void
    private typealias MRGetInfoFunc = @convention(c) (DispatchQueue, @escaping (CFDictionary?) -> Void) -> Void
    private typealias MRSendCommandFunc = @convention(c) (Int32, CFDictionary?) -> Bool

    private var registerFunc: MRRegisterFunc?
    private var getInfoFunc: MRGetInfoFunc?
    private var sendCommandFunc: MRSendCommandFunc?

    public private(set) var isAvailable: Bool = false

    public init() {
        loadFramework()
    }

    private func loadFramework() {
        let path = "/System/Library/PrivateFrameworks/MediaRemote.framework/MediaRemote"
        guard let handle = dlopen(path, RTLD_NOW) else {
            return
        }

        if let regSym = dlsym(handle, "MRMediaRemoteRegisterForNowPlayingNotifications") {
            registerFunc = unsafeBitCast(regSym, to: MRRegisterFunc.self)
        }
        if let getInfoSym = dlsym(handle, "MRMediaRemoteGetNowPlayingInfo") {
            getInfoFunc = unsafeBitCast(getInfoSym, to: MRGetInfoFunc.self)
        }
        if let sendSym = dlsym(handle, "MRMediaRemoteSendCommand") {
            sendCommandFunc = unsafeBitCast(sendSym, to: MRSendCommandFunc.self)
        }

        if getInfoFunc != nil {
            isAvailable = true
            registerFunc?(DispatchQueue.main)
        }
    }

    public func fetchNowPlayingInfo(completion: @escaping (MediaItem?) -> Void) {
        guard let getInfoFunc = getInfoFunc else {
            completion(nil)
            return
        }

        getInfoFunc(DispatchQueue.main) { infoDict in
            guard let dict = infoDict as? [String: Any] else {
                completion(nil)
                return
            }

            let title = (dict["kMRMediaRemoteNowPlayingInfoTitle"] as? String) ?? ""
            let artist = (dict["kMRMediaRemoteNowPlayingInfoArtist"] as? String) ?? ""
            let album = (dict["kMRMediaRemoteNowPlayingInfoAlbum"] as? String) ?? ""
            let duration = (dict["kMRMediaRemoteNowPlayingInfoDuration"] as? Double) ?? 0
            let elapsed = (dict["kMRMediaRemoteNowPlayingInfoElapsedTime"] as? Double) ?? 0
            let playbackRate = (dict["kMRMediaRemoteNowPlayingInfoPlaybackRate"] as? Double) ?? 0

            var artwork: NSImage?
            if let artworkData = dict["kMRMediaRemoteNowPlayingInfoArtworkData"] as? Data {
                artwork = NSImage(data: artworkData)
            }

            guard !title.isEmpty || !artist.isEmpty else {
                completion(nil)
                return
            }

            let item = MediaItem(
                title: title,
                artist: artist,
                album: album,
                isPlaying: playbackRate > 0,
                position: elapsed,
                duration: duration,
                artwork: artwork,
                sourceApp: "Universal"
            )
            completion(item)
        }
    }

    public func togglePlayPause() -> Bool {
        guard let sendCommand = sendCommandFunc else { return false }
        return sendCommand(2, nil) // kMRTogglePlayPause = 2
    }

    public func nextTrack() -> Bool {
        guard let sendCommand = sendCommandFunc else { return false }
        return sendCommand(4, nil) // kMRNextTrack = 4
    }

    public func previousTrack() -> Bool {
        guard let sendCommand = sendCommandFunc else { return false }
        return sendCommand(5, nil) // kMRPreviousTrack = 5
    }
}
