import SwiftUI
import Combine

@MainActor
public final class SideNotchStudioManager: ObservableObject {
    public static let shared = SideNotchStudioManager()
    
    private let userDefaultsKey = "SideNotch_UniversalApps_v1"
    private let orientationKey = "SideNotch_Orientation_v1"
    private let themeKey = "SideNotch_Theme_v1"
    private let verticalPosKey = "SideNotch_VerticalPos_v1"
    private let widthKey = "SideNotch_PillWidth_v1"
    
    @Published public var state: NotchState = .glance
    @Published public var gearSeparation: CGFloat = 0
    @Published public var selectedAppId: UUID?
    
    // User Configurations
    @Published public var orientation: BezelOrientation = .right {
        didSet { saveSettings() }
    }
    @Published public var activeTheme: StudioTheme = .cupertinoAurora {
        didSet { saveSettings() }
    }
    @Published public var verticalPositionRatio: CGFloat = 0.26 {
        didSet { saveSettings() }
    }
    @Published public var customPillWidth: CGFloat = 58 {
        didSet { saveSettings() }
    }
    
    // Pinned Universal Apps
    @Published public var apps: [NotchAppItem] = [] {
        didSet { saveApps() }
    }
    
    public init() {
        loadSettings()
        loadApps()
    }
    
    // MARK: - Notch State Controls
    
    public func toggleNotch() {
        SideNotchHapticsEngine.shared.playSelectionTick()
        withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
            if state == .dormant {
                state = .glance
                gearSeparation = 0
            } else {
                state = .dormant
                gearSeparation = 0
            }
        }
    }
    
    public func setGearDetached(_ detached: Bool) {
        if detached {
            SideNotchHapticsEngine.shared.playSurfaceTensionPop()
        } else {
            SideNotchHapticsEngine.shared.playDockingSnap()
        }
        withAnimation(.spring(response: 0.38, dampingFraction: 0.68)) {
            if detached {
                state = .detachedGear
                gearSeparation = 28
            } else {
                state = .glance
                gearSeparation = 0
            }
        }
    }
    
    public func toggleExpandedCard(for app: NotchAppItem? = nil) {
        SideNotchHapticsEngine.shared.playSelectionTick()
        if let app = app {
            selectedAppId = app.id
        } else if selectedAppId == nil {
            selectedAppId = activeApps.first?.id
        }
        
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            state = (state == .expandedCard) ? .glance : .expandedCard
        }
    }
    
    // MARK: - App Actions & Deep Linking
    
    public var activeApps: [NotchAppItem] {
        apps.filter { $0.isEnabled }
    }
    
    public var selectedApp: NotchAppItem? {
        apps.first(where: { $0.id == selectedAppId }) ?? activeApps.first
    }
    
    public func launchApp(_ app: NotchAppItem) {
        SideNotchHapticsEngine.shared.playAppLaunchPulse()
        guard let scheme = app.urlScheme, let url = URL(string: scheme) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    public func addCustomApp(_ app: NotchAppItem) {
        apps.append(app)
        selectedAppId = app.id
        SideNotchHapticsEngine.shared.playDockingSnap()
    }
    
    public func removeApp(id: UUID) {
        apps.removeAll(where: { $0.id == id })
    }
    
    public func updateAppProgress(id: UUID, progress: Double, label: String? = nil) {
        if let index = apps.firstIndex(where: { $0.id == id }) {
            apps[index].progress = min(1.0, max(0.0, progress))
            if let label = label {
                apps[index].primaryLabel = label
            }
        }
    }
    
    // MARK: - Persistence
    
    private func saveSettings() {
        UserDefaults.standard.set(orientation.rawValue, forKey: orientationKey)
        UserDefaults.standard.set(activeTheme.rawValue, forKey: themeKey)
        UserDefaults.standard.set(Double(verticalPositionRatio), forKey: verticalPosKey)
        UserDefaults.standard.set(Double(customPillWidth), forKey: widthKey)
    }
    
    private func loadSettings() {
        if let savedOrientation = UserDefaults.standard.string(forKey: orientationKey),
           let parsed = BezelOrientation(rawValue: savedOrientation) {
            self.orientation = parsed
        }
        if let savedTheme = UserDefaults.standard.string(forKey: themeKey),
           let parsed = StudioTheme(rawValue: savedTheme) {
            self.activeTheme = parsed
        }
        let pos = UserDefaults.standard.double(forKey: verticalPosKey)
        if pos > 0.1 && pos < 0.9 {
            self.verticalPositionRatio = CGFloat(pos)
        }
        let width = UserDefaults.standard.double(forKey: widthKey)
        if width >= 48 && width <= 72 {
            self.customPillWidth = CGFloat(width)
        }
    }
    
    private func saveApps() {
        if let encoded = try? JSONEncoder().encode(apps) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    private func loadApps() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([NotchAppItem].self, from: data),
           !decoded.isEmpty {
            self.apps = decoded
        } else {
            // Default Showcase Apps
            self.apps = Self.defaultShowcaseApps
        }
    }
    
    public static var defaultShowcaseApps: [NotchAppItem] {
        [
            NotchAppItem(
                name: "Claude",
                category: .ai,
                iconSymbol: "sparkles",
                accentHexColor: "#D97706",
                progress: 0.73,
                primaryLabel: "73%",
                secondaryPreview: "Claude 3.7 Sonnet Quota • 4h reset",
                urlScheme: "claude://",
                quickActions: [
                    AppQuickAction(title: "New Chat", iconSymbol: "plus.bubble.fill", actionUrl: "claude://new"),
                    AppQuickAction(title: "Check Limits", iconSymbol: "chart.bar.fill")
                ]
            ),
            NotchAppItem(
                name: "Spotify",
                category: .media,
                iconSymbol: "waveform",
                accentHexColor: "#1DB954",
                progress: 0.58,
                primaryLabel: "Playing",
                secondaryPreview: "Starboy — The Weeknd",
                urlScheme: "spotify://",
                quickActions: [
                    AppQuickAction(title: "Pause", iconSymbol: "pause.fill"),
                    AppQuickAction(title: "Next Track", iconSymbol: "forward.fill")
                ]
            ),
            NotchAppItem(
                name: "GitHub",
                category: .dev,
                iconSymbol: "chevron.left.forwardslash.chevron.right",
                accentHexColor: "#A855F7",
                progress: 0.88,
                primaryLabel: "1.2k ★",
                secondaryPreview: "SideNotch: Build #42 Passing",
                urlScheme: "github://",
                quickActions: [
                    AppQuickAction(title: "View PRs", iconSymbol: "arrow.triangle.pull"),
                    AppQuickAction(title: "Actions", iconSymbol: "bolt.fill")
                ]
            ),
            NotchAppItem(
                name: "Battery",
                category: .system,
                iconSymbol: "bolt.batteryblock.fill",
                accentHexColor: "#22C55E",
                progress: 0.84,
                primaryLabel: "84%",
                secondaryPreview: "Fast Charging (32m to 100%)",
                quickActions: [
                    AppQuickAction(title: "Low Power", iconSymbol: "battery.50")
                ]
            )
        ]
    }
}
