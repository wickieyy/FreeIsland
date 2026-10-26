import SwiftUI

public struct BatteryHUDView: View {
    let percentage: Int
    let isCharging: Bool

    public var body: some View {
        HStack(spacing: 10) {
            // Glowing green lightning icon
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.25))
                    .frame(width: 22, height: 22)

                Image(systemName: "bolt.fill")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.green)
            }

            Text(isCharging ? "MagSafe Connected" : "Battery")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)

            Spacer()

            HStack(spacing: 4) {
                Text("\(percentage)%")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.green)

                Image(systemName: "battery.100")
                    .font(.system(size: 12))
                    .foregroundColor(.green)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 34)
    }
}
