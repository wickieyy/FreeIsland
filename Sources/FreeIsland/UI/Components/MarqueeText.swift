import SwiftUI

public struct MarqueeText: View {
    let text: String
    let font: Font
    let color: Color

    public init(_ text: String, font: Font = .system(size: 14, weight: .semibold), color: Color = .white) {
        self.text = text
        self.font = font
        self.color = color
    }

    public var body: some View {
        Text(text)
            .font(font)
            .foregroundColor(color)
            .lineLimit(1)
            .truncationMode(.tail)
    }
}
