import AppIntents

public struct SideNotchShortcutsProvider: AppShortcutsProvider {
    public init() {}
    
    public static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ToggleNotchIntent(),
            phrases: [
                "Toggle \(.applicationName)",
                "Toggle Side Notch in \(.applicationName)",
                "Show \(.applicationName)"
            ],
            shortTitle: "Toggle Notch",
            systemImageName: "sidebar.right"
        )
        AppShortcut(
            intent: PeekSideNotchIntent(),
            phrases: [
                "Peek \(.applicationName)",
                "Peek Side Notch in \(.applicationName)",
                "Glance \(.applicationName)"
            ],
            shortTitle: "Peek Notch",
            systemImageName: "capsule.portrait"
        )
        AppShortcut(
            intent: OpenSideNotchIntent(),
            phrases: [
                "Open \(.applicationName)",
                "Launch \(.applicationName)"
            ],
            shortTitle: "Open Notch",
            systemImageName: "arrow.up.left.and.arrow.down.right"
        )
    }
}
