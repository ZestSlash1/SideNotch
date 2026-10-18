import SwiftUI

public struct ExpandedBentoOverlay: View {
    public let metrics: [NotchMetric]
    public let onClose: () -> Void
    
    public init(metrics: [NotchMetric], onClose: @escaping () -> Void) {
        self.metrics = metrics
        self.onClose = onClose
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("LIVE TELEMETRY")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.5))
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            
            ForEach(metrics) { item in
                HStack(spacing: 10) {
                    Circle()
                        .fill(item.accentColor)
                        .frame(width: 8, height: 8)
                    Text(item.name)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.white)
                    Spacer()
                    Text("\(Int(item.percentage * 100))%")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundStyle(item.accentColor)
                }
            }
        }
        .padding(16)
        .frame(width: 210)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.ultraThinMaterial)
                .environment(\.colorScheme, .dark)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.14), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.45), radius: 20, x: -8, y: 10)
    }
}
