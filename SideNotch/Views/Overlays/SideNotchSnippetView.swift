import SwiftUI
import AppIntents

/// A compact, high-precision system telemetry card displayed when Side Notch is triggered via
/// AppIntents (Action Button, Siri, or Shortcuts HUD) outside the main app.
public struct SideNotchSnippetView: View {
    public let apps: [NotchAppItem]
    
    public init(apps: [NotchAppItem] = SideNotchStudioManager.shared.activeApps) {
        self.apps = apps
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header Row: Status & Live Indicator
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.cyan)
                        .frame(width: 8, height: 8)
                        .shadow(color: .cyan.opacity(0.8), radius: 4)
                    
                    Text("SIDE NOTCH")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .tracking(1.4)
                        .foregroundStyle(.white)
                }
                
                Spacer()
                
                Text("\(apps.count) APPS ACTIVE")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color.white.opacity(0.6))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(Color.white.opacity(0.1)))
            }
            
            // App Telemetry Row: Horizontal micro-gauges
            HStack(spacing: 10) {
                ForEach(apps.prefix(4)) { app in
                    VStack(spacing: 6) {
                        ZStack {
                            Circle()
                                .stroke(Color.white.opacity(0.12), lineWidth: 2.5)
                                .frame(width: 38, height: 38)
                            
                            Circle()
                                .trim(from: 0, to: CGFloat(app.progress))
                                .stroke(app.color, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                                .frame(width: 38, height: 38)
                                .rotationEffect(.degrees(-90))
                            
                            Image(systemName: app.iconSymbol)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                        
                        Text(app.name)
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                        
                        Text(app.primaryLabel)
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundStyle(app.color)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.white.opacity(0.06))
                    )
                }
            }
            
            // Action Row: Quick Launch link
            HStack {
                if let media = apps.first(where: { $0.category == .media }), !media.secondaryPreview.isEmpty {
                    HStack(spacing: 5) {
                        Image(systemName: "music.note")
                            .font(.system(size: 10))
                            .foregroundStyle(Color.green)
                        Text(media.secondaryPreview)
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.75))
                            .lineLimit(1)
                    }
                } else {
                    Text("Hold Action Button to re-glance")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.5))
                }
                
                Spacer()
                
                Button(intent: OpenSideNotchIntent()) {
                    HStack(spacing: 4) {
                        Text("Open Notch")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 12))
                    }
                    .foregroundStyle(Color.cyan)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.black.opacity(0.92))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.15), lineWidth: 0.8)
        )
    }
}
