import AppIntents

public struct SideNotchShortcutsProvider: AppShortcutsProvider {
    public init() {}
    
    public static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ToggleNotchIntent(),
            phrases: [
                "Toggle \(.applicationName)",
                "Toggle Side Notch in \(.applicationName)",
                "Open Side Notch"
            ],
            shortTitle: "Toggle Notch",
            systemImageName: "sidebar.right"
        )
    }
}
