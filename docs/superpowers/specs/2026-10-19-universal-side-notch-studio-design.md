# Universal Side Notch Studio Architecture & Design Specification

**Date**: 2026-10-19  
**Status**: Approved for Implementation  
**Target Environment**: iOS 17.0+, Xcode 15/16, Swift 5.9/6.0  
**Project**: SideNotch (Universal App Notch & Studio)  
**Bundle Identifier**: `com.sidenotch.app`

---

## 1. Executive Summary

This specification re-architects the **Side Notch** iOS application from a static telemetry prototype into an **extensible, hardware-grade Universal App Dock & Studio**. 
Key deliverables:
1. **Universal App Model & Extensibility**: Any iOS application (Spotify, Claude, WhatsApp, Uber, GitHub, Battery, Fitness, Custom) can be pinned to the bezel with live circular telemetry rings, status snippets, deep-link app launching, and interactive preview cards.
2. **Hardware-Grade Bezel Fusion**: Pure OLED black (`#000000`) body with G2 continuous concave fillets, 0.5pt specular rim lighting reflecting screen light, and bidirectional bezel anchoring (Left Bezel for Action Button / Right Bezel for Power Button).
3. **Apple `CHHapticEngine` Audio-Tactile Dynamics**: Real physical fluid haptics with continuous drag tension, snap threshold ticks, liquid pinch-off pop, and docking impacts.
4. **The Side Studio Configurator**: A luxury frosted glass command deck replacing the test bench, featuring an App Drawer, Custom App Creator, Calibrator Slider Deck (Y-offset, width, fillet), and Wallpaper Gallery.
5. **Full Persistence**: All pinned apps, metrics, and calibration settings persist across launches via `UserDefaults`.

---

## 2. Architecture & File Layout

```text
SideNotch/
├── App/
│   └── SideNotchApp.swift                     # App entry point, boots Studio & Haptics
├── Models/
│   ├── NotchAppItem.swift                     # Universal App item model, actions, and categories
│   ├── NotchState.swift                       # .dormant, .glance, .detachedGear, .expandedCard
│   ├── BezelOrientation.swift                 # .right (Power button), .left (Action button)
│   └── StudioTheme.swift                      # Wallpaper & backdrop themes
├── Shapes/
│   └── BezelLiquidShape.swift                 # Bi-directional (left/right) G2 concave-convex shape
├── Haptics/
│   └── SideNotchHapticsEngine.swift           # Apple CHHapticEngine tactile audio/haptic coordinator
├── Managers/
│   ├── SideNotchStudioManager.swift           # Centralized @MainActor store with UserDefaults persistence
│   └── SideNotchPiPManager.swift              # Safe PiP manager with auto-inline disabled
├── Views/
│   ├── Components/
│   │   ├── UniversalAppGaugeItem.swift        # Neon micro-ring with dynamic SF Symbol/glyph & %
│   │   ├── SpecularRimOverlay.swift           # 0.5pt titanium specular light reflection stroke
│   │   └── QuickActionCapsule.swift           # Interactive 1-tap app action pills
│   ├── Overlays/
│   │   ├── ExpandedAppBentoCard.swift         # Glassmorphic live preview card with app launch
│   │   └── AppDrawerSheet.swift               # Bottom sheet to toggle & reorder apps
│   ├── Studio/
│   │   ├── SideStudioDeckView.swift           # In-app frosted command deck & switcher
│   │   ├── CustomAppCreatorView.swift         # Add any app modal (URL Scheme, SF Symbol, Color)
│   │   └── NotchCalibratorView.swift          # Live vertical position & width slider controls
│   ├── SideLiquidNotchView.swift              # Hardware-anchored metaball canvas & gesture engine
│   ├── WallpaperBackdropView.swift            # Curated Apple-grade dynamic wallpaper themes
│   └── ContentView.swift                      # Root view integrating Notch & Studio Deck
└── Intents/
    ├── ToggleNotchIntent.swift                # Action Button toggle intent
    ├── CycleAppPresetIntent.swift             # Action Button cycle active app intent
    └── SideNotchShortcutsProvider.swift       # Siri & Action Button shortcuts
```

---

## 3. Data & Extensibility Specifications

### 3.1 `NotchAppItem.swift`
Represents any app pinned to the bezel:
```swift
import SwiftUI

public struct NotchAppItem: Identifiable, Codable, Sendable, Equatable {
    public var id: UUID
    public var name: String
    public var category: AppCategory
    public var iconSymbol: String
    public var accentHexColor: String
    public var progress: Double // 0.0 to 1.0
    public var primaryLabel: String
    public var secondaryPreview: String
    public var urlScheme: String?
    public var isEnabled: Bool
    public var quickActions: [AppQuickAction]
    
    public enum AppCategory: String, Codable, Sendable, CaseIterable {
        case media
        case ai
        case dev
        case social
        case delivery
        case system
        case custom
    }
}

public struct AppQuickAction: Identifiable, Codable, Sendable, Equatable {
    public var id: UUID
    public var title: String
    public var iconSymbol: String
    public var actionUrl: String?
}
```

### 3.2 Curated App Catalog Defaults:
- **Spotify**: `progress: 0.65`, `primaryLabel: "Playing"`, `secondaryPreview: "Starboy — The Weeknd"`, `accentHex: "#1DB954"`, `urlScheme: "spotify://"`.
- **Claude**: `progress: 0.73`, `primaryLabel: "73%"`, `secondaryPreview: "Claude 3.7 Quota: 4h resets"`, `accentHex: "#D97706"`, `urlScheme: "claude://"`.
- **GitHub**: `progress: 0.88`, `primaryLabel: "1.2k ★"`, `secondaryPreview: "SideNotch: Build #42 Passing"`, `accentHex: "#A855F7"`, `urlScheme: "github://"`.
- **Uber**: `progress: 0.40`, `primaryLabel: "8m ETA"`, `secondaryPreview: "Toyota Camry (XYZ 123)"`, `accentHex: "#000000"`, `urlScheme: "uber://"`.
- **Battery**: `progress: 0.84`, `primaryLabel: "84%"`, `secondaryPreview: "Fast Charging (32m to full)"`, `accentHex: "#22C55E"`.

---

## 4. Hardware Bezel Fusion & Core Haptics Engine

### 4.1 Bi-Directional Bezel Shape (`BezelLiquidShape.swift`)
- Supports `.right` (flush against `rect.maxX`) and `.left` (flush against `rect.minX`).
- Concave entry/exit fillets mathematically curve directly into the display boundary:
  ```swift
  public enum BezelOrientation: String, Codable, Sendable {
      case right // Power button side
      case left  // Action button side
  }
  ```
- Layered with `SpecularRimOverlay`: A 0.5pt linear gradient border (`white.opacity(0.35)` to `clear`) giving the illusion of ambient glass reflection.

### 4.2 Apple `CHHapticEngine` Architecture (`SideNotchHapticsEngine.swift`)
- Allocates `CHHapticEngine` on device initialization.
- **Continuous Elastic Rumble**: When user drags the notch away from the bezel, generates continuous vibration proportional to drag distance (`intensity = min(1.0, distance / 60)`).
- **Surface Tension Pop**: When the gear or node detaches past the 25pt threshold, plays a sharp transient `CHHapticEvent` (sharpness: 0.9, intensity: 1.0).
- **Docking Snap**: When returning to the bezel, plays a low-frequency damped transient impact.

---

## 5. Side Studio In-App Interface

1. **Frosted Command Deck (`SideStudioDeckView.swift`)**:
   - Modern floating bar at the bottom with segmented tab controls:
     - 📱 **Active Apps**: Toggle, reorder, and live-adjust app values.
     - 🎨 **Appearance & Bezel**: Select Left/Right bezel side, vertical Y-offset slider (aligns with physical buttons), width slider, theme wallpaper picker.
     - ➕ **Add App**: Launches `CustomAppCreatorView`.
2. **Deep-Link Launching**:
   - Tapping an active app in the notch or in the Bento card executes `UIApplication.shared.open(url)` to instantly launch that app on the iPhone.
3. **Persistence**:
   - `SideNotchStudioManager` serializes `[NotchAppItem]`, `BezelOrientation`, and calibration offsets into `UserDefaults.standard` on every change.

---

## 6. Verification and Acceptance Criteria
1. Notch must sit **100% flush against the screen bezel** on physical iPhone (zero offset gap).
2. Tapping any app gauge or expanded Bento action triggers deep-linking and tactile feedback.
3. Adding a custom app via the Studio immediately adds a new circular neon micro-widget to the notch.
4. Dragging the notch stretches and snaps cleanly with `CHHapticEngine` feedback.
5. All settings persist after quitting and relaunching the app.
