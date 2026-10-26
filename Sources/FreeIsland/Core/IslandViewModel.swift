import SwiftUI
import Combine

public enum IslandState: Equatable {
    case idle
    case compact
    case expanded
}

public final class IslandViewModel: ObservableObject {
    public static let shared = IslandViewModel()

    @Published public var state: IslandState = .idle
    @Published public var isPinned: Bool = false
    @Published public var isHovered: Bool = false

    private var exitHysteresisTimer: Timer?
    private var cancellables = Set<AnyCancellable>()

    public init() {
        // Observe media changes to automatically transition between idle and compact
        MediaService.shared.$hasActiveMedia
            .receive(on: RunLoop.main)
            .sink { [weak self] hasMedia in
                guard let self = self else { return }
                if !self.isHovered && !self.isPinned {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                        self.state = hasMedia ? .compact : .idle
                    }
                }
            }
            .store(in: &cancellables)
    }

    public func onMouseEnter() {
        exitHysteresisTimer?.invalidate()
        exitHysteresisTimer = nil
        isHovered = true

        withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
            self.state = .expanded
        }
    }

    public func onMouseExit() {
        guard !isPinned else { return }
        exitHysteresisTimer?.invalidate()
        exitHysteresisTimer = Timer.scheduledTimer(withTimeInterval: 0.35, repeats: false) { [weak self] _ in
            guard let self = self, !self.isPinned else { return }
            self.isHovered = false
            withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                self.state = MediaService.shared.hasActiveMedia ? .compact : .idle
            }
        }
    }

    public func togglePin() {
        isPinned.toggle()
        if isPinned {
            state = .expanded
        } else if !isHovered {
            state = MediaService.shared.hasActiveMedia ? .compact : .idle
        }
    }

    public func calculateDimensions(notch: NotchInfo) -> (width: CGFloat, height: CGFloat, cornerRadius: CGFloat) {
        switch state {
        case .idle:
            if notch.hasPhysicalNotch {
                return (notch.notchRect.width, notch.notchRect.height, notch.cornerRadius)
            } else {
                return (180, 32, 16)
            }
        case .compact:
            if notch.hasPhysicalNotch {
                return (notch.notchRect.width + 64, notch.notchRect.height + 4, 14)
            } else {
                return (220, 34, 17)
            }
        case .expanded:
            return (380, 158, 24)
        }
    }
}
