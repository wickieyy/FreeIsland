import SwiftUI

public struct FluidSlider: View {
    @Binding var progress: Double
    let onSeek: (Double) -> Void

    @State private var isDragging: Bool = false
    @State private var dragValue: Double = 0

    public init(progress: Binding<Double>, onSeek: @escaping (Double) -> Void) {
        self._progress = progress
        self.onSeek = onSeek
    }

    public var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let currentFraction = isDragging ? dragValue : progress
            let filledWidth = max(0, min(width * CGFloat(currentFraction), width))

            ZStack(alignment: .leading) {
                // Background track
                Capsule()
                    .fill(Color.white.opacity(0.18))
                    .frame(height: isDragging ? 5 : 3.5)

                // Filled progress
                Capsule()
                    .fill(Color.white)
                    .frame(width: filledWidth, height: isDragging ? 5 : 3.5)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        isDragging = true
                        let fraction = Double(gesture.location.x / width)
                        dragValue = max(0, min(fraction, 1.0))
                    }
                    .onEnded { gesture in
                        let fraction = Double(gesture.location.x / width)
                        let target = max(0, min(fraction, 1.0))
                        isDragging = false
                        onSeek(target)
                    }
            )
            .animation(.interactiveSpring(response: 0.25), value: isDragging)
        }
        .frame(height: 12)
    }
}
