import Foundation
import IOKit.ps

public struct PowerSnapshot: Equatable {
    public let percentage: Int
    public let isCharging: Bool
    public let isPluggedIn: Bool

    public static let empty = PowerSnapshot(percentage: 100, isCharging: false, isPluggedIn: false)
}

public final class PowerService: ObservableObject {
    public static let shared = PowerService()

    @Published public private(set) var currentPower: PowerSnapshot = .empty
    public var onPluggedIn: ((PowerSnapshot) -> Void)?

    private var runLoopSource: CFRunLoopSource?
    private var wasPluggedIn: Bool?

    public init() {
        startMonitoring()
    }

    public func startMonitoring() {
        refreshPower()

        let context = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        let callback: IOPowerSourceCallbackType = { context in
            guard let context = context else { return }
            let service = Unmanaged<PowerService>.fromOpaque(context).takeUnretainedValue()
            DispatchQueue.main.async {
                service.refreshPower()
            }
        }

        if let source = IOPSNotificationCreateRunLoopSource(callback, context)?.takeRetainedValue() {
            self.runLoopSource = source
            CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .defaultMode)
        }
    }

    public func refreshPower() {
        guard let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
              let sources = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue() as? [CFTypeRef],
              let firstSource = sources.first,
              let desc = IOPSGetPowerSourceDescription(snapshot, firstSource)?.takeUnretainedValue() as? [String: Any] else {
            return
        }

        let curCap = (desc[kIOPSCurrentCapacityKey] as? Int) ?? 100
        let maxCap = (desc[kIOPSMaxCapacityKey] as? Int) ?? 100
        let isCharging = (desc[kIOPSIsChargingKey] as? Bool) ?? false
        let powerState = (desc[kIOPSPowerSourceStateKey] as? String) ?? ""
        let isPluggedIn = (powerState == kIOPSACPowerValue)

        let percentage = maxCap > 0 ? Int((Double(curCap) / Double(maxCap)) * 100) : 100
        let newPower = PowerSnapshot(percentage: percentage, isCharging: isCharging, isPluggedIn: isPluggedIn)

        let previousPluggedIn = wasPluggedIn
        wasPluggedIn = isPluggedIn
        self.currentPower = newPower

        // Detect MagSafe connected transition
        if let previous = previousPluggedIn, !previous && isPluggedIn {
            onPluggedIn?(newPower)
        }
    }

    deinit {
        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .defaultMode)
        }
    }
}
