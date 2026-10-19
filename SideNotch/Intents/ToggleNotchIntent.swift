import AppIntents
import SwiftUI

/// Primary Intent mapped to the iPhone Action Button, Back Tap, or Shortcuts.
/// When triggered, it activates Side Notch and immediately presents it to the user.
public struct ToggleNotchIntent: AppIntent {
    public static var title: LocalizedStringResource = "Toggle Side Notch"
    public static var description = IntentDescription("Activates and toggles the interactive Side Notch on screen.")
    public static var openAppWhenRun: Bool = true
    
    public init() {}
    
    @MainActor
    public func perform() async throws -> some IntentResult & ProvidesDialog {
        SideNotchStudioManager.shared.toggleNotch()
        SideNotchHapticsEngine.shared.playDockingSnap()
        return .result(dialog: "Side Notch Active")
    }
}

/// Headless telemetry glance intent for the Action Button.
/// Pops up a floating Dynamic Island / HUD capsule over any currently active app
/// without switching tasks.
public struct PeekSideNotchIntent: AppIntent {
    public static var title: LocalizedStringResource = "Peek Side Notch"
    public static var description = IntentDescription("Displays active pinned apps & live telemetry in a floating system pill.")
    public static var openAppWhenRun: Bool = false
    
    public init() {}
    
    @MainActor
    public func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let activeApps = SideNotchStudioManager.shared.activeApps
        
        let summary: String
        if let media = activeApps.first(where: { $0.category == .media }), !media.secondaryPreview.isEmpty {
            summary = "Playing: \(media.secondaryPreview)"
        } else if let first = activeApps.first {
            summary = "\(first.name): \(first.primaryLabel) • \(activeApps.count) apps active"
        } else {
            summary = "Side Notch: \(activeApps.count) apps pinned"
        }
        
        return .result(
            dialog: IntentDialog(stringLiteral: summary),
            view: SideNotchSnippetView(apps: activeApps)
        )
    }
}

/// Explicit open intent for opening Side Notch directly into glance mode.
public struct OpenSideNotchIntent: AppIntent {
    public static var title: LocalizedStringResource = "Open Side Notch"
    public static var description = IntentDescription("Launches Side Notch directly in glance mode with hardware haptics.")
    public static var openAppWhenRun: Bool = true
    
    public init() {}
    
    @MainActor
    public func perform() async throws -> some IntentResult {
        SideNotchStudioManager.shared.state = .glance
        SideNotchStudioManager.shared.gearSeparation = 0
        SideNotchHapticsEngine.shared.playDockingSnap()
        return .result()
    }
}
