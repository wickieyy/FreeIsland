import Foundation
import CoreGraphics

public final class BrightnessHUDService {
    public static let shared = BrightnessHUDService()
    public var onBrightnessChanged: ((Float) -> Void)?

    private typealias GetBrightnessFunc = @convention(c) (CGDirectDisplayID, UnsafeMutablePointer<Float>) -> Int32
    private var getBrightnessFunc: GetBrightnessFunc?

    private var pollTimer: Timer?
    private var lastBrightness: Float = -1

    public init() {
        loadFramework()
        startPolling()
    }

    private func loadFramework() {
        let path = "/System/Library/PrivateFrameworks/DisplayServices.framework/DisplayServices"
        if let handle = dlopen(path, RTLD_NOW) {
            if let sym = dlsym(handle, "DisplayServicesGetBrightness") {
                getBrightnessFunc = unsafeBitCast(sym, to: GetBrightnessFunc.self)
            }
        }
    }

    private func startPolling() {
        // Check brightness at 2Hz
        pollTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkBrightness()
        }
    }

    public func checkBrightness() {
        guard let getBrightness = getBrightnessFunc else { return }
        var brightness: Float = 0
        let status = getBrightness(CGMainDisplayID(), &brightness)
        if status == 0 {
            if lastBrightness >= 0 && abs(brightness - lastBrightness) > 0.015 {
                lastBrightness = brightness
                onBrightnessChanged?(brightness)
            } else if lastBrightness < 0 {
                lastBrightness = brightness
            }
        }
    }
}
