# Side Notch iOS Architecture & Modularization Specification

**Date**: 2026-10-19  
**Status**: Draft for Review  
**Target Environment**: iOS 17.0+, Xcode 15/16, Swift 5.9/6.0  
**Project Name**: SideNotch  
**Bundle Identifier**: `com.sidenotch.app`

---

## 1. Executive Summary

This specification defines the architectural modularization and complete Xcode project structure for the **Side Notch** iOS application. The implementation extracts a monolithic SwiftUI master file into clean, decoupled modules conforming to modern SwiftUI best practices:
- **Models**: Clean data definitions (`NotchMetric`, `NotchState`).
- **Shapes**: Custom geometric vector paths with concave and convex fillets (`RightBezelLiquidShape`).
- **Views**: Granular reusable micro-widgets, overlays, and main canvas metaball rendering.
- **Managers**: MainActor state coordination and Picture-in-Picture (`AVPictureInPictureVideoCallViewController`) background overlay lifecycle.
- **Intents**: Native iOS 17 `AppIntent` and `AppShortcutsProvider` integration for hardware Action Button triggering.
- **Project Structure**: Native `SideNotch.xcodeproj` with `project.pbxproj`, asset catalogs, and configured `Info.plist` supporting `UIBackgroundModes` (`audio`, `fetch`, `processing`).

---

## 2. Directory Structure

```text
g:/PROJECT X/Notchy/
├── SideNotch.xcodeproj/
│   └── project.pbxproj
├── SideNotch/
│   ├── App/
│   │   └── SideNotchApp.swift
│   ├── Models/
│   │   ├── NotchMetric.swift
│   │   └── NotchState.swift
│   ├── Shapes/
│   │   └── RightBezelLiquidShape.swift
│   ├── Views/
│   │   ├── Components/
│   │   │   ├── CustomMetricGlyph.swift
│   │   │   ├── CircularGaugeItem.swift
│   │   │   └── ControlPillButton.swift
│   │   ├── Overlays/
│   │   │   └── ExpandedBentoOverlay.swift
│   │   ├── SideLiquidNotchView.swift
│   │   ├── WallpaperMockupBackground.swift
│   │   └── ContentView.swift
│   ├── Managers/
│   │   ├── SideNotchStateManager.swift
│   │   └── SideNotchPiPManager.swift
│   ├── Intents/
│   │   ├── ToggleNotchIntent.swift
│   │   └── SideNotchShortcutsProvider.swift
│   └── Resources/
│       ├── Info.plist
│       └── Assets.xcassets/
│           ├── Contents.json
│           ├── AppIcon.appiconset/
│           │   └── Contents.json
│           └── AccentColor.colorset/
│               └── Contents.json
├── Package.swift
└── docs/
    └── superpowers/
        └── specs/
            └── 2026-10-19-side-notch-ios-modularization-design.md
```

---

## 3. Module & Component Specifications

### 3.1 Models (`SideNotch/Models/`)

#### `NotchMetric.swift`
- Defines micro-widget data:
  ```swift
  import SwiftUI

  public struct NotchMetric: Identifiable, Sendable {
      public let id: UUID
      public let name: String
      public let percentage: Double
      public let accentColor: Color
      public let iconType: IconType

      public enum IconType: Sendable {
          case claudeSpark
          case openAISpiral
          case perplexityCrystal
      }

      public init(
          id: UUID = UUID(),
          name: String,
          percentage: Double,
          accentColor: Color,
          iconType: IconType
      ) {
          self.id = id
          self.name = name
          self.percentage = percentage
          self.accentColor = accentColor
          self.iconType = iconType
      }
  }
  ```

#### `NotchState.swift`
- Defines lifecycle and visual geometry modes of the notch:
  ```swift
  import Foundation

  public enum NotchState: String, CaseIterable, Sendable {
      case dormant       // 8pt edge bezel strip
      case glance        // 58pt vertical 3-gauge pill
      case detachedGear  // 58pt pill + separated settings circle
      case expandedCard  // 210pt glassmorphism Bento telemetry card
  }
  ```

---

### 3.2 Shapes (`SideNotch/Shapes/`)

#### `RightBezelLiquidShape.swift`
- Conforms to `Shape`.
- Draws a vertical container flush with `rect.maxX` (the right hardware bezel), with smooth inward-curving concave fillets at top and bottom entry points and convex rounded corners on the inner left edge:
  - Top concave fillet: `(maxX, rect.minY)` curving to `(maxX - filletRadius, minY)`.
  - Top-left convex corner: radius `cornerRadius`.
  - Inner left vertical edge.
  - Bottom-left convex corner: radius `cornerRadius`.
  - Bottom concave fillet: `(maxX - filletRadius, maxY)` curving to `(maxX, rect.maxY)`.

---

### 3.3 Views (`SideNotch/Views/`)

#### `Views/Components/CustomMetricGlyph.swift`
- Renders the vector iconography for each metric type:
  - `.claudeSpark`: 6 rotated capsules (12-ray starburst effect).
  - `.openAISpiral`: SF Symbol `"hurricane"` (custom weighted icon).
  - `.perplexityCrystal`: Stacked `"sparkles"` + `"asterisk"`.

#### `Views/Components/CircularGaugeItem.swift`
- 34x34pt circular neon progress track:
  - Base ring: `Color(white: 0.16)`, line width 3.2.
  - Active ring: `trim(from: 0, to: metric.percentage)` with `.round` cap and glow shadow.
  - Center: `CustomMetricGlyph`.
  - Sub-label: Rounded percentage text `Int(percentage * 100)%`.

#### `Views/Components/ControlPillButton.swift`
- Glass capsule button used in demo bar to quickly trigger `.dormant`, `.glance`, or `.detachedGear`.

#### `Views/Overlays/ExpandedBentoOverlay.swift`
- 210pt width `.ultraThinMaterial` card displaying live telemetry metrics, color-coded indicators, and dismiss button.

#### `Views/SideLiquidNotchView.swift`
- Coordinates:
  - **Layer A**: Liquid black metaball background using SwiftUI `Canvas` with `.alphaThreshold(min: 0.5, color: .black)` and `.blur(radius: 8)` fusing `MainPill` and `GearNode`.
  - **Layer B**: Crisp vector gauges and detached gear button.
  - **Layer C**: `ExpandedBentoOverlay`.
  - **Gestures**: Horizontal drag (swipe left to expand, swipe right to collapse) and vertical drag (swipe down to pop gear, swipe up to merge).
  - Connects to `@ObservedObject var stateManager: SideNotchStateManager`.

#### `Views/WallpaperMockupBackground.swift`
- Renders multi-stop linear gradient replicating iOS dynamic wallpaper.
- Contains bottom demo control dock.

#### `Views/ContentView.swift`
- Root screen combining `WallpaperMockupBackground` and `SideLiquidNotchView`.
- Houses an invisible `PiPAnchorView` (`UIViewRepresentable`) that hooks into `SideNotchPiPManager.shared.setupPiP(with:)`.

---

### 3.4 Managers (`SideNotch/Managers/`)

#### `SideNotchStateManager.swift`
- Singleton `@MainActor final class SideNotchStateManager: ObservableObject`.
- Published properties: `state: NotchState`, `gearSeparation: CGFloat`, `metrics: [NotchMetric]`.
- Methods:
  - `toggleNotch()`: Toggles `.dormant` $\leftrightarrow$ `.glance`.
  - `setGearDetached(_ detached: Bool)`: Animates gear separation offset.
  - `toggleBentoCard()`: Transitions `.glance` $\leftrightarrow$ `.expandedCard`.

#### `SideNotchPiPManager.swift`
- `@MainActor final class SideNotchPiPManager: NSObject, ObservableObject, AVPictureInPictureControllerDelegate`
- Manages `AVPictureInPictureVideoCallViewController` hosting `SideLiquidNotchView`.
- Configures `AVAudioSession`:
  ```swift
  try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: [.mixWithOthers])
  try? AVAudioSession.sharedInstance().setActive(true)
  ```
- Exposes `togglePiP()`, `startPiP()`, `stopPiP()`, and published `isPiPActive: Bool`.

---

### 3.5 App Intents (`SideNotch/Intents/`)

#### `ToggleNotchIntent.swift`
- Conforms to `AppIntent`:
  ```swift
  import AppIntents

  public struct ToggleNotchIntent: AppIntent {
      public static var title: LocalizedStringResource = "Toggle Side Notch"
      public static var description = IntentDescription("Toggles the Side Notch display state or PiP overlay.")
      public static var openAppWhenRun: Bool = false

      public init() {}

      @MainActor
      public func perform() async throws -> some IntentResult {
          SideNotchStateManager.shared.toggleNotch()
          return .result()
      }
  }
  ```

#### `SideNotchShortcutsProvider.swift`
- Conforms to `AppShortcutsProvider`:
  ```swift
  import AppIntents

  public struct SideNotchShortcutsProvider: AppShortcutsProvider {
      public static var appShortcuts: [AppShortcut] {
          AppShortcut(
              intent: ToggleNotchIntent(),
              phrases: [
                  "Toggle \(.applicationName)",
                  "Toggle Side Notch in \(.applicationName)"
              ],
              shortTitle: "Toggle Notch",
              systemImageName: "sidebar.right"
          )
      }
  }
  ```

---

### 3.6 Configuration & Project Setup (`SideNotch/Resources/` & `SideNotch.xcodeproj`)

#### `Info.plist`
- `UIBackgroundModes`:
  - `audio`
  - `fetch`
  - `processing`
- `UILaunchScreen`: standard dictionary.
- `CFBundleIdentifier`: `com.sidenotch.app`.
- `CFBundleShortVersionString`: `1.0`.
- `CFBundleVersion`: `1`.

#### `SideNotch.xcodeproj/project.pbxproj`
- Fully formed PBX project file:
  - PBXNativeTarget: `SideNotch` (Application, iOS 17.0).
  - PBXSourcesBuildPhase: Compiles all `.swift` files across App, Models, Shapes, Views, Managers, Intents.
  - PBXResourcesBuildPhase: Copies `Assets.xcassets` and `Info.plist`.
  - PBXFrameworksBuildPhase: Links `AVKit.framework`, `AVFoundation.framework`, `Combine.framework`.
  - Build Settings: `SWIFT_VERSION = 5.9`, `IPHONEOS_DEPLOYMENT_TARGET = 17.0`, `TARGETED_DEVICE_FAMILY = "1"`, `INFOPLIST_FILE = SideNotch/Resources/Info.plist`.

---

## 4. Verification and Validation Plan

1. **Static Analysis & File Integrity**:
   - Verify every file exists in its designated directory.
   - Verify all cross-file type references (`NotchMetric`, `NotchState`, `RightBezelLiquidShape`, `CustomMetricGlyph`, `CircularGaugeItem`, `ExpandedBentoOverlay`, `SideLiquidNotchView`, `SideNotchStateManager`, `SideNotchPiPManager`, `ToggleNotchIntent`) resolve with exact signatures.
2. **SwiftPM Build & Syntax Validation**:
   - Validate `Package.swift` manifest syntax and compile readiness.
3. **Xcode Project Descriptor Validation**:
   - Parse `project.pbxproj` syntax and verify all file references, build phases, and target identifiers match.
4. **Info.plist Validation**:
   - Verify `UIBackgroundModes` array contains `audio`, `fetch`, and `processing`.
