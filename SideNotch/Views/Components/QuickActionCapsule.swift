import SwiftUI

public struct QuickActionCapsule: View {
    public let title: String
    public let iconSymbol: String
    public let action: () -> Void
    
    public init(title: String, iconSymbol: String, action: @escaping () -> Void) {
        self.title = title
        self.iconSymbol = iconSymbol
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: iconSymbol)
                    .font(.system(size: 11, weight: .bold))
                Text(title)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.12))
            )
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.18), lineWidth: 0.6)
            )
        }
        .buttonStyle(.plain)
    }
}
