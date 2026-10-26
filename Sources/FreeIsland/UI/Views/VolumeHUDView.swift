import SwiftUI

public struct VolumeHUDView: View {
    let volume: Float
    let isMuted: Bool

    private var iconName: String {
        if isMuted || volume <= 0.001 {
            return "speaker.slash.fill"
        } else if volume < 0.33 {
            return "speaker.wave.1.fill"
        } else if volume < 0.66 {
            return "speaker.wave.2.fill"
        } else {
            return "speaker.wave.3.fill"
        }
    }

    public var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 20)

            // Volume bar
            GeometryReader { geo in
                let width = geo.size.width
                let fillWidth = isMuted ? 0 : width * CGFloat(min(max(volume, 0), 1))

                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 6)

                    Capsule()
                        .fill(Color.white)
                        .frame(width: fillWidth, height: 6)
                }
                .frame(maxHeight: .infinity)
            }
            .frame(height: 6)

            Text(isMuted ? "Mute" : "\(Int(volume * 100))%")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
                .frame(width: 38, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .frame(height: 34)
    }
}
