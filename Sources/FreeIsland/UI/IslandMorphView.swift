import SwiftUI
import AppKit

public struct IslandMorphView: View {
    @ObservedObject var viewModel = IslandViewModel.shared
    @ObservedObject var geometryEngine = NotchGeometryEngine.shared
    @ObservedObject var mediaService = MediaService.shared

    public var body: some View {
        let notch = geometryEngine.currentNotch
        let dims = viewModel.currentDimensions

        VStack(spacing: 0) {
            ZStack(alignment: .top) {
                // Background Morphing Pill
                RoundedRectangle(cornerRadius: dims.cornerRadius, style: .continuous)
                    .fill(Color.black)
                    .overlay(
                        RoundedRectangle(cornerRadius: dims.cornerRadius, style: .continuous)
                            .stroke(
                                Color.white.opacity(viewModel.isExpanded ? 0.15 : 0.05),
                                lineWidth: 1
                            )
                    )
                    .shadow(
                        color: Color.black.opacity(viewModel.isExpanded ? 0.45 : 0.0),
                        radius: 12,
                        x: 0,
                        y: 6
                    )

                // Dynamic Island Content
                Group {
                    switch viewModel.mode {
                    case .idle:
                        if !notch.hasPhysicalNotch {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 7, height: 7)
                                Text("FreeIsland")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.white.opacity(0.35))
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            Color.clear
                        }

                    case .compactMedia:
                        CompactMediaView(
                            item: mediaService.currentTrack,
                            isPhysicalNotch: notch.hasPhysicalNotch,
                            notchWidth: notch.notchRect.width
                        )
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))

                    case .expandedMedia:
                        ExpandedMediaView()
                            .transition(.opacity.combined(with: .scale(scale: 0.92)))

                    case .hud(let hudType):
                        Group {
                            switch hudType {
                            case .volume(let level, let isMuted):
                                VolumeHUDView(volume: level, isMuted: isMuted)
                            case .brightness(let level):
                                BrightnessHUDView(brightness: level)
                            case .battery(let percentage, let isCharging):
                                BatteryHUDView(percentage: percentage, isCharging: isCharging)
                            }
                        }
                        .padding(.top, notch.hasPhysicalNotch ? notch.notchRect.height : 0)
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
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

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}
