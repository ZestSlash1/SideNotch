import SwiftUI
import AppIntents

@main
public struct SideNotchApp: App {
    public init() {
        SideNotchShortcutsProvider.updateAppShortcutParameters()
    }
    
    public var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    handleIncomingURL(url)
                }
        }
    }
    
    private func handleIncomingURL(_ url: URL) {
        SideNotchHapticsEngine.shared.playDockingSnap()
        let action = url.host ?? url.path
        
        withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
            if action.contains("toggle") {
                SideNotchStudioManager.shared.toggleNotch()
            } else {
                SideNotchStudioManager.shared.state = .glance
                SideNotchStudioManager.shared.gearSeparation = 0
            }
        }
    }
}
