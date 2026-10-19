import SwiftUI

public struct ExpandedAppBentoCard: View {
    @ObservedObject private var studioManager = SideNotchStudioManager.shared
    public let app: NotchAppItem
    public let onClose: () -> Void
    
    public init(app: NotchAppItem, onClose: @escaping () -> Void) {
        self.app = app
        self.onClose = onClose
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header Bar
            HStack {
                HStack(spacing: 8) {
                    Circle()
                        .fill(app.color)
                        .frame(width: 10, height: 10)
                    Text(app.name.uppercased())
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.8))
                }
                
                Spacer()
                
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
            
            // Primary status & Preview
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(app.primaryLabel)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Image(systemName: app.iconSymbol)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(app.color)
                }
                
                Text(app.secondaryPreview)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.75))
                    .lineLimit(2)
            }
            
            // Progress Bar
            GeometryReader { barGeo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.12))
                        .frame(height: 6)
                    Capsule()
                        .fill(app.color)
                        .frame(width: barGeo.size.width * CGFloat(app.progress), height: 6)
                        .shadow(color: app.color.opacity(0.6), radius: 4, x: 0, y: 0)
                }
            }
            .frame(height: 6)
            
            // Quick Actions & Deep Link Launch Button
            HStack(spacing: 8) {
                ForEach(app.quickActions.prefix(2)) { action in
                    QuickActionCapsule(title: action.title, iconSymbol: action.iconSymbol) {
                        SideNotchHapticsEngine.shared.playSelectionTick()
                        if let urlString = action.actionUrl, let url = URL(string: urlString) {
                            UIApplication.shared.open(url)
                        }
                    }
                }
                
                Spacer()
                
                if app.urlScheme != nil {
                    Button {
                        studioManager.launchApp(app)
                    } label: {
                        HStack(spacing: 4) {
                            Text("Open")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                            Image(systemName: "arrow.up.forward.app")
                                .font(.system(size: 11, weight: .bold))
                        }
                        .foregroundStyle(.black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(Capsule().fill(.white))
                    }
                }
            }
        }
        .padding(18)
        .frame(width: 240)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .environment(\.colorScheme, .dark)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.24),
                            Color.white.opacity(0.06)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: .black.opacity(0.55), radius: 24, x: -8, y: 12)
    }
}
