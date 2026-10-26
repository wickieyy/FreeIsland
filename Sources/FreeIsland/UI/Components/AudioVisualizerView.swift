import SwiftUI

public struct AudioVisualizerView: View {
    let isPlaying: Bool
    let barColor: Color

    @State private var barHeights: [CGFloat] = [0.3, 0.7, 0.4, 0.9, 0.5]
    private let timer = Timer.publish(every: 0.15, on: .main, in: .common).autoconnect()

    public init(isPlaying: Bool, barColor: Color = Color.green) {
        self.isPlaying = isPlaying
        self.barColor = barColor
    }

    public var body: some View {
        HStack(spacing: 2.5) {
            ForEach(0..<barHeights.count, id: \.self) { index in
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(barColor)
                    .frame(width: 3, height: isPlaying ? barHeights[index] * 14 : 3)
                    .animation(
                        isPlaying ? .easeInOut(duration: 0.15) : .easeOut(duration: 0.2),
                        value: barHeights[index]
                    )
            }
        }
        .frame(height: 14)
        .onReceive(timer) { _ in
            guard isPlaying else { return }
            barHeights = (0..<5).map { _ in CGFloat.random(in: 0.25...1.0) }
        }
    }
}
