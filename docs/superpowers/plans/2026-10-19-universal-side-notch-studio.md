# Universal Side Notch Studio Implementation Plan

> **For agentic workers:** Fast-track execution. Deliver pristine, production-ready Swift code across all modules, zero stubs, zero placeholders.

**Goal:** Transform Side Notch into a universal, extensible iOS app dock and configurator studio with Apple `CHHapticEngine`, custom app builder, bezel fusion, and deep linking.

**Architecture:** A `@MainActor` studio manager (`SideNotchStudioManager`) persisting `[NotchAppItem]` and position calibration to `UserDefaults`, driving a hardware-anchored liquid notch (`SideLiquidNotchView`), tactile engine (`SideNotchHapticsEngine`), and an in-app frosted glass Studio Deck (`SideStudioDeckView`).

**Tech Stack:** iOS 17.0+, SwiftUI, CoreHaptics, AppIntents, AVKit, Combine.

**Spec:** `docs/superpowers/specs/2026-10-19-universal-side-notch-studio-design.md`

## Global Constraints
- Target platform: iOS 17.0+
- Bundle identifier: `com.sidenotch.app`
- Language version: Swift 5.9 / 6.0
- Strict Sendable / @MainActor concurrency
- Zero placeholders or TODOs in any file.

---

### Task 1: Universal App Models & Orientation
- Create `SideNotch/Models/BezelOrientation.swift`
- Create `SideNotch/Models/StudioTheme.swift`
- Create `SideNotch/Models/NotchAppItem.swift`

### Task 2: Apple Core Haptics Engine
- Create `SideNotch/Haptics/SideNotchHapticsEngine.swift`

### Task 3: Bi-directional Bezel Shape & Specular Rim
- Create `SideNotch/Shapes/BezelLiquidShape.swift`
- Create `SideNotch/Views/Components/SpecularRimOverlay.swift`

### Task 4: Studio Manager Store & Persistence
- Create `SideNotch/Managers/SideNotchStudioManager.swift`

### Task 5: Micro-Widgets & Expanded Bento Card
- Create `SideNotch/Views/Components/UniversalAppGaugeItem.swift`
- Create `SideNotch/Views/Overlays/ExpandedAppBentoCard.swift`

### Task 6: Studio Interface & Custom App Builder
- Create `SideNotch/Views/WallpaperBackdropView.swift`
- Create `SideNotch/Views/Studio/NotchCalibratorView.swift`
- Create `SideNotch/Views/Studio/CustomAppCreatorView.swift`
- Create `SideNotch/Views/Studio/SideStudioDeckView.swift`

### Task 7: Master Assembly, Action Button Intents & Xcode Project
- Update `SideNotch/Views/SideLiquidNotchView.swift`
- Update `SideNotch/Views/ContentView.swift`
- Update `SideNotch/Intents/ToggleNotchIntent.swift`
- Update `SideNotch.xcodeproj/project.pbxproj`

### Task 8: Verification & Push to GitHub
- Verify all file references and syntax.
- Commit and push to `origin/master`.
