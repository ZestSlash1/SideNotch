import SwiftUI

public struct WallpaperBackdropView: View {
    @ObservedObject private var studioManager = SideNotchStudioManager.shared
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Base Theme Gradient
            LinearGradient(
                colors: studioManager.activeTheme.gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Subtle ambient mesh orbs for depth
            if studioManager.activeTheme != .oledBlack {
                Circle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 320, height: 320)
                    .blur(radius: 60)
                    .offset(x: -80, y: -160)
                
                Circle()
                    .fill(Color.black.opacity(0.2))
                    .frame(width: 280, height: 280)
                    .blur(radius: 50)
                    .offset(x: 100, y: 200)
            }
        }
        .ignoresSafeArea()
    }
}
