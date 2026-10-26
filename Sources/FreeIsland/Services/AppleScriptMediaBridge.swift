import AppKit
import Foundation

public final class AppleScriptMediaBridge {
    public static let shared = AppleScriptMediaBridge()

    private let musicCheckScript = """
    if application "Music" is running then
        tell application "Music"
            set pState to (player state as string)
            if pState is not "stopped" then
                set tName to name of current track
                set tArtist to artist of current track
                set tAlbum to album of current track
                set tPos to player position
                set tDur to duration of current track
                return pState & "|||" & tName & "|||" & tArtist & "|||" & tAlbum & "|||" & tPos & "|||" & tDur
            end if
        end tell
    end if
    return "inactive"
    """

    private let spotifyCheckScript = """
    if application "Spotify" is running then
        tell application "Spotify"
            set pState to (player state as string)
            if pState is not "stopped" then
                set tName to name of current track
                set tArtist to artist of current track
                set tAlbum to album of current track
                set tPos to player position
                set tDur to (duration of current track) / 1000
                set artUrl to artwork url of current track
                return pState & "|||" & tName & "|||" & tArtist & "|||" & tAlbum & "|||" & tPos & "|||" & tDur & "|||" & artUrl
            end if
        end tell
    end if
    return "inactive"
    """

    private var cachedSpotifyArtworkUrl: String?
    private var cachedArtwork: NSImage?

    public func fetchTrackInfo() -> MediaItem? {
        // Try Spotify first
        if let spotifyItem = querySpotify() {
            return spotifyItem
        }
        // Then try Apple Music
        if let musicItem = queryMusic() {
            return musicItem
        }
        return nil
    }

    private func querySpotify() -> MediaItem? {
        guard let output = runScript(spotifyCheckScript), output != "inactive" else { return nil }
        let parts = output.components(separatedBy: "|||")
        guard parts.count >= 6 else { return nil }

        let state = parts[0]
        let title = parts[1]
        let artist = parts[2]
        let album = parts[3]
        let pos = Double(parts[4]) ?? 0
        let dur = Double(parts[5]) ?? 0
        let artUrl = parts.count > 6 ? parts[6] : ""

        var artwork = cachedArtwork
        if !artUrl.isEmpty && artUrl != cachedSpotifyArtworkUrl {
            cachedSpotifyArtworkUrl = artUrl
            if let url = URL(string: artUrl), let data = try? Data(contentsOf: url), let img = NSImage(data: data) {
                cachedArtwork = img
                artwork = img
            }
        }

        return MediaItem(
            title: title.isEmpty ? "Unknown Title" : title,
            artist: artist.isEmpty ? "Unknown Artist" : artist,
            album: album,
            isPlaying: (state == "playing"),
            position: pos,
            duration: dur,
            artwork: artwork,
            sourceApp: "Spotify"
        )
    }

    private func queryMusic() -> MediaItem? {
        guard let output = runScript(musicCheckScript), output != "inactive" else { return nil }
        let parts = output.components(separatedBy: "|||")
        guard parts.count >= 6 else { return nil }

        let state = parts[0]
        let title = parts[1]
        let artist = parts[2]
        let album = parts[3]
        let pos = Double(parts[4]) ?? 0
        let dur = Double(parts[5]) ?? 0

        // Fetch Music artwork if track changed
        let artwork = fetchMusicArtwork()

        return MediaItem(
            title: title.isEmpty ? "Unknown Title" : title,
            artist: artist.isEmpty ? "Unknown Artist" : artist,
            album: album,
            isPlaying: (state == "playing"),
            position: pos,
            duration: dur,
            artwork: artwork,
            sourceApp: "Music"
        )
    }

    private func fetchMusicArtwork() -> NSImage? {
        let artScript = """
        tell application "Music"
            try
                set rawData to (raw data of artwork 1 of current track)
                return rawData
            end try
        end tell
        """
        var error: NSDictionary?
        if let script = NSAppleScript(source: artScript) {
            let descriptor = script.executeAndReturnError(&error)
            let data = descriptor.data
            if !data.isEmpty {
                return NSImage(data: data)
            }
        }
        return nil
    }

    public func togglePlayPause() {
        let script = """
        if application "Spotify" is running then
            tell application "Spotify" to playpause
        else if application "Music" is running then
            tell application "Music" to playpause
        end if
        """
        _ = runScript(script)
    }

    public func nextTrack() {
        let script = """
        if application "Spotify" is running then
            tell application "Spotify" to next track
        else if application "Music" is running then
            tell application "Music" to next track
        end if
        """
        _ = runScript(script)
    }

    public func previousTrack() {
        let script = """
        if application "Spotify" is running then
            tell application "Spotify" to previous track
        else if application "Music" is running then
            tell application "Music" to previous track
        end if
        """
        _ = runScript(script)
    }

    public func seek(to seconds: Double) {
        let script = """
        if application "Spotify" is running then
            tell application "Spotify" to set player position to \(seconds)
        else if application "Music" is running then
            tell application "Music" to set player position to \(seconds)
        end if
        """
        _ = runScript(script)
    }

    private func runScript(_ source: String) -> String? {
        var error: NSDictionary?
        guard let script = NSAppleScript(source: source) else { return nil }
        let descriptor = script.executeAndReturnError(&error)
        return descriptor.stringValue
    }
}
