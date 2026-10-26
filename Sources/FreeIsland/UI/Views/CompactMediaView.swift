import SwiftUI
import AppKit

public struct CompactMediaView: View {
    let item: MediaItem
    let isPhysicalNotch: Bool

    public var body: some View {
        HStack(spacing: 0) {
            // Leading side: Mini Album Artwork
            HStack {
                if let artwork = item.artwork {
                    Image(nsImage: artwork)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 20, height: 20)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                } else {
                    Image(systemName: "music.note")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.green)
                        .frame(width: 20, height: 20)
                }
            }
            .padding(.leading, 8)

            Spacer(minLength: 0)

            // Trailing side: Audio Visualizer
            HStack {
                AudioVisualizerView(
                    isPlaying: item.isPlaying,
                    barColor: item.sourceApp == "Spotify" ? Color.green : Color.pink
                )
            }
            .padding(.trailing, 10)
        }
        .frame(height: 32)
    }
}
