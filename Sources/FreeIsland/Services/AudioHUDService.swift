import CoreAudio
import Foundation

public final class AudioHUDService {
    public static let shared = AudioHUDService()

    public var onVolumeChanged: ((Float, Bool) -> Void)?

    private var defaultOutputDeviceID: AudioObjectID = 0
    private var isMuted: Bool = false
    private var lastVolume: Float = -1

    // 'vmvm' = kAudioHardwareServiceDeviceProperty_VirtualMainVolume
    private let virtualMainVolumeSelector: AudioObjectPropertySelector = 0x766d766d

    public init() {
        setupListener()
    }

    private func setupListener() {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        var deviceID = AudioObjectID(0)
        var dataSize = UInt32(MemoryLayout<AudioObjectID>.size)

        let status = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0,
            nil,
            &dataSize,
            &deviceID
        )

        guard status == noErr && deviceID != 0 else { return }
        self.defaultOutputDeviceID = deviceID

        // Register listener for virtual volume changes
        var volumeAddress = AudioObjectPropertyAddress(
            mSelector: virtualMainVolumeSelector,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )

        AudioObjectAddPropertyListenerBlock(
            deviceID,
            &volumeAddress,
            DispatchQueue.main
        ) { [weak self] _, _ in
            self?.readVolume()
        }

        // Register listener for mute changes
        var muteAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyMute,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )

        AudioObjectAddPropertyListenerBlock(
            deviceID,
            &muteAddress,
            DispatchQueue.main
        ) { [weak self] _, _ in
            self?.readMute()
        }
    }

    public func readVolume() {
        guard defaultOutputDeviceID != 0 else { return }

        var volumeAddress = AudioObjectPropertyAddress(
            mSelector: virtualMainVolumeSelector,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )

        var volume: Float32 = 0
        var dataSize = UInt32(MemoryLayout<Float32>.size)

        var status = AudioObjectGetPropertyData(
            defaultOutputDeviceID,
            &volumeAddress,
            0,
            nil,
            &dataSize,
            &volume
        )

        if status != noErr {
            // Fall back to kAudioDevicePropertyVolumeScalar
            volumeAddress.mSelector = kAudioDevicePropertyVolumeScalar
            status = AudioObjectGetPropertyData(
                defaultOutputDeviceID,
                &volumeAddress,
                0,
                nil,
                &dataSize,
                &volume
            )
        }

        if status == noErr {
            if abs(volume - lastVolume) > 0.005 {
                lastVolume = volume
                onVolumeChanged?(volume, isMuted || volume <= 0.001)
            }
        }
    }

    private func readMute() {
        guard defaultOutputDeviceID != 0 else { return }

        var muteAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyMute,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )

        var muted: UInt32 = 0
        var dataSize = UInt32(MemoryLayout<UInt32>.size)

        let status = AudioObjectGetPropertyData(
            defaultOutputDeviceID,
            &muteAddress,
            0,
            nil,
            &dataSize,
            &muted
        )

        if status == noErr {
            self.isMuted = (muted != 0)
            if lastVolume >= 0 {
                onVolumeChanged?(lastVolume, isMuted)
            }
        }
    }
}
