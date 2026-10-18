import SwiftUI

public struct WallpaperMockupBackground: View {
    @ObservedObject private var stateManager = SideNotchStateManager.shared
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Gradient matching reference wallpaper
            LinearGradient(
                colors: [
                    Color(red: 0.98, green: 0.55, blue: 0.45),
                    Color(red: 0.72, green: 0.75, blue: 0.96),
                    Color(red: 0.85, green: 0.78, blue: 0.75)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Bottom Floating Control Bar to Test States Easily
            VStack {
                Spacer()
                HStack(spacing: 12) {
                    ControlPillButton(title: "Bezel Peek") {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                            stateManager.state = .dormant
                            stateManager.gearSeparation = 0
                        }
                    }
                    ControlPillButton(title: "Glance (Left Phone)") {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                            stateManager.state = .glance
                            stateManager.gearSeparation = 0
                        }
                    }
                    ControlPillButton(title: "Pop Gear (Right Phone)") {
                        stateManager.setGearDetached(true)
                    }
                }
                .padding(.bottom, 50)
            }
        }
    }
}
