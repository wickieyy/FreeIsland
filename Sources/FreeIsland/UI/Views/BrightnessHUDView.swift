import SwiftUI

public struct BrightnessHUDView: View {
    let brightness: Float

    public var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "sun.max.fill")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.yellow)
                .frame(width: 20)

            // Brightness bar
            GeometryReader { geo in
                let width = geo.size.width
                let fillWidth = width * CGFloat(min(max(brightness, 0), 1))

                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 6)

                    Capsule()
                        .fill(Color.yellow.opacity(0.95))
                        .frame(width: fillWidth, height: 6)
                }
                .frame(maxHeight: .infinity)
            }
            .frame(height: 6)

            Text("\(Int(brightness * 100))%")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
                .frame(width: 38, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .frame(height: 34)
    }
}
