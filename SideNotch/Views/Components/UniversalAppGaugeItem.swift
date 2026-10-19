import SwiftUI

public struct UniversalAppGaugeItem: View {
    public let app: NotchAppItem
    public var isSelected: Bool = false
    
    public init(app: NotchAppItem, isSelected: Bool = false) {
        self.app = app
        self.isSelected = isSelected
    }
    
    public var body: some View {
        VStack(spacing: 4) {
            ZStack {
                // Background dark ring
                Circle()
                    .stroke(Color(white: 0.16), lineWidth: 3.2)
                    .frame(width: 34, height: 34)
                
                // Active Neon Progress Arc
                Circle()
                    .trim(from: 0, to: CGFloat(app.progress))
                    .stroke(
                        app.color,
                        style: StrokeStyle(lineWidth: 3.2, lineCap: .round)
                    )
                    .frame(width: 34, height: 34)
                    .rotationEffect(.degrees(-90))
                    .shadow(color: app.color.opacity(0.55), radius: 3, x: 0, y: 0)
                
                // App Icon (SF Symbol)
                Image(systemName: app.iconSymbol)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .scaleEffect(isSelected ? 1.08 : 1.0)
            
            // Primary status / percentage
            Text(app.primaryLabel)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.92))
                .lineLimit(1)
        }
    }
}
