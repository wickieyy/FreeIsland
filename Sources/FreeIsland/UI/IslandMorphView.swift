import SwiftUI
import AppKit

public struct IslandMorphView: View {
    @ObservedObject var viewModel = IslandViewModel.shared
    @ObservedObject var geometryEngine = NotchGeometryEngine.shared
    @ObservedObject var mediaService = MediaService.shared

    public var body: some View {
        let notch = geometryEngine.currentNotch
        let dims = viewModel.calculateDimensions(notch: notch)

        ZStack(alignment: .top) {
            // Background Shape
            RoundedRectangle(cornerRadius: dims.cornerRadius, style: .continuous)
                .fill(Color.black)
                .overlay(
                    RoundedRectangle(cornerRadius: dims.cornerRadius, style: .continuous)
                        .stroke(Color.white.opacity(viewModel.state == .expanded ? 0.14 : 0.04), lineWidth: 1)
                )
                .shadow(
                    color: Color.black.opacity(viewModel.state == .expanded ? 0.45 : 0.0),
                    radius: 12,
                    x: 0,
                    y: 6
                )

            // Content Transitions
            Group {
                switch viewModel.state {
                case .idle:
                    if !notch.hasPhysicalNotch {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 8, height: 8)
                            Text("FreeIsland")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.white.opacity(0.35))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        // Empty / flush with physical notch
                        Color.clear
                    }

                case .compact:
                    CompactMediaView(
                        item: mediaService.currentTrack,
                        isPhysicalNotch: notch.hasPhysicalNotch
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))

                case .expanded:
                    ExpandedMediaView()
                        .transition(.opacity.combined(with: .scale(scale: 0.92)))
                }
            }
        }
        .frame(width: dims.width, height: dims.height)
        .clipped()
        .onHover { isHovered in
            if isHovered {
                viewModel.onMouseEnter()
            } else {
                viewModel.onMouseExit()
            }
        }
    }
}
