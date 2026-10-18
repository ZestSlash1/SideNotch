import SwiftUI

public struct CustomMetricGlyph: View {
    public let type: NotchMetric.IconType
    
    public init(type: NotchMetric.IconType) {
        self.type = type
    }
    
    public var body: some View {
        switch type {
        case .claudeSpark:
            ZStack {
                ForEach(0..<6, id: \.self) { i in
                    Capsule()
                        .fill(Color.white)
                        .frame(width: 1.6, height: 13)
                        .rotationEffect(.degrees(Double(i) * 30))
                }
            }
        case .openAISpiral:
            Image(systemName: "hurricane")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white)
        case .perplexityCrystal:
            ZStack {
                Image(systemName: "sparkles")
                Image(systemName: "asterisk")
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundStyle(.white)
        }
    }
}
