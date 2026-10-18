import SwiftUI

public struct CircularGaugeItem: View {
    public let metric: NotchMetric
    
    public init(metric: NotchMetric) {
        self.metric = metric
    }
    
    public var body: some View {
        VStack(spacing: 4) {
            ZStack {
                // Dark background track
                Circle()
                    .stroke(Color(white: 0.16), lineWidth: 3.2)
                    .frame(width: 34, height: 34)
                
                // Active Neon Progress Arc
                Circle()
                    .trim(from: 0, to: metric.percentage)
                    .stroke(
                        metric.accentColor,
                        style: StrokeStyle(lineWidth: 3.2, lineCap: .round)
                    )
                    .frame(width: 34, height: 34)
                    .rotationEffect(.degrees(-90))
                    .shadow(color: metric.accentColor.opacity(0.45), radius: 3, x: 0, y: 0)
                
                // Center Icon
                CustomMetricGlyph(type: metric.iconType)
            }
            
            // Percentage Label
            Text("\(Int(metric.percentage * 100))%")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.92))
        }
    }
}
