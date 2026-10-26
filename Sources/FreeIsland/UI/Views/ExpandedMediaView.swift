import SwiftUI
import AppKit

public struct ExpandedMediaView: View {
    @ObservedObject var mediaService = MediaService.shared
    @ObservedObject var geometryEngine = NotchGeometryEngine.shared

    public var body: some View {
        let track = mediaService.currentTrack
        let notch = geometryEngine.currentNotch
        let topPadding: CGFloat = notch.hasPhysicalNotch ? (notch.notchRect.height + 8) : 14

        VStack(spacing: 12) {
            // Header: Album Artwork, Title, Artist, Source
            HStack(spacing: 12) {
                // Artwork
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.1))

                    if let artwork = track.artwork {
                        Image(nsImage: artwork)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Image(systemName: "music.note")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .frame(width: 54, height: 54)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(color: .black.opacity(0.4), radius: 6, x: 0, y: 3)

                // Track & Artist Info
                VStack(alignment: .leading, spacing: 3) {
                    MarqueeText(
                        track.title.isEmpty ? "Not Playing" : track.title,
                        font: .system(size: 15, weight: .bold)
                    )

                    Text(track.artist.isEmpty ? "Open Music or Spotify" : track.artist)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(1)

                    if !track.sourceApp.isEmpty {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(track.sourceApp == "Spotify" ? Color.green : Color.pink)
                                .frame(width: 6, height: 6)

                            Text(track.sourceApp)
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .padding(.top, 1)
                    }
                }

                Spacer()

                // Visualizer in corner
                AudioVisualizerView(
                    isPlaying: track.isPlaying,
                    barColor: track.sourceApp == "Spotify" ? Color.green : Color.pink
                )
                .padding(.trailing, 4)
            }

            // Progress Slider
            VStack(spacing: 4) {
                FluidSlider(
                    progress: Binding(
                        get: { track.progress },
                        set: { newProgress in
                            mediaService.seek(to: newProgress)
                        }
                    ),
                    onSeek: { target in
                        mediaService.seek(to: target)
                    }
                )

                HStack {
                    Text(track.formattedPosition)
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(.white.opacity(0.55))

                    Spacer()

                    Text(track.formattedDuration)
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(.white.opacity(0.55))
                }
            }

            // Playback Controls
            HStack(spacing: 32) {
                // Previous Track
                Button(action: {
                    mediaService.previousTrack()
                }) {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white.opacity(0.85))
                }
                .buttonStyle(PlainButtonStyle())

                // Play / Pause
                Button(action: {
                    mediaService.togglePlayPause()
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 36, height: 36)

                        Image(systemName: track.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.black)
                            .offset(x: track.isPlaying ? 0 : 1)
                    }
                }
                .buttonStyle(PlainButtonStyle())

                // Next Track
                Button(action: {
                    mediaService.nextTrack()
                }) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white.opacity(0.85))
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.top, 2)
        }
        .padding(.horizontal, 16)
        .padding(.top, topPadding)
        .padding(.bottom, 14)
    }
}
