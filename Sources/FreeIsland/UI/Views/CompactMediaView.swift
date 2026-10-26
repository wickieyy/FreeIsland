import SwiftUI
import AppKit

public struct CompactMediaView: View {
    let item: MediaItem
    let isPhysicalNotch: Bool
    let notchWidth: CGFloat

    public init(item: MediaItem, isPhysicalNotch: Bool, notchWidth: CGFloat = 180) {
        self.item = item
        self.isPhysicalNotch = isPhysicalNotch
        self.notchWidth = notchWidth
    }

    public var body: some View {
        HStack(spacing: 0) {
            // Leading side: Mini Album Artwork
            HStack {
                if let artwork = item.artwork {
                    Image(nsImage: artwork)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 19, height: 19)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                } else {
                    Image(systemName: "music.note")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.green)
                        .frame(width: 19, height: 19)
                }
            }
            .frame(width: 36)
            .padding(.leading, 4)

            // Center Spacer matching physical notch
            Spacer(minLength: isPhysicalNotch ? notchWidth : 16)

            // Trailing side: Audio Visualizer
            HStack {
                AudioVisualizerView(
                    isPlaying: item.isPlaying,
                    barColor: item.sourceApp == "Spotify" ? Color.green : Color.pink
                )
            }
            .frame(width: 36)
            .padding(.trailing, 4)
        }
        .frame(height: 32)
    }
}
