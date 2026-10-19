import SwiftUI
import UIKit

public struct ContentView: View {
    @ObservedObject private var studioManager = SideNotchStudioManager.shared
    @Environment(\.scenePhase) private var scenePhase
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // 1. Dynamic Wallpaper Backdrop
            WallpaperBackdropView()
            
            // 2. Hardware Bezel Notch
            SideLiquidNotchView()
            
            // 3. Floating Side Studio Command Deck
            VStack {
                Spacer()
                SideStudioDeckView()
                    .padding(.bottom, 20)
            }
        }
        .ignoresSafeArea(.keyboard)
        .preferredColorScheme(.dark)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                    studioManager.state = .glance
                    studioManager.gearSeparation = 0
                }
                SideNotchHapticsEngine.shared.playDockingSnap()
            }
        }
    }
}
