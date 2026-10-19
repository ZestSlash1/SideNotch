import AppIntents

public struct ToggleNotchIntent: AppIntent {
    public static var title: LocalizedStringResource = "Toggle Side Notch"
    public static var description = IntentDescription("Toggles the Side Notch display between dormant and active glance states.")
    public static var openAppWhenRun: Bool = false
    
    public init() {}
    
    @MainActor
    public func perform() async throws -> some IntentResult {
        SideNotchStudioManager.shared.toggleNotch()
        return .result()
    }
}
