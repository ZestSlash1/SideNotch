# Side Notch iOS Modularization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create the complete Xcode project structure for the Side Notch iOS app, modularizing the monolithic SwiftUI code into clean files across Models, Shapes, Views, Managers, and Intents, configuring Info.plist with audio/fetch/processing background modes and adding an Action Button AppIntent.

**Architecture:** A native SwiftUI application centered on a `@MainActor` state manager (`SideNotchStateManager`) coordinating interactive liquid metaball notch states (`.dormant`, `.glance`, `.detachedGear`, `.expandedCard`) with an `AVPictureInPictureVideoCallViewController` manager (`SideNotchPiPManager`) and an iOS 17 `AppIntent` (`ToggleNotchIntent`) for hardware Action Button integration.

**Tech Stack:** iOS 17.0+, SwiftUI, AppIntents, AVKit, AVFoundation, Combine, Xcode PBX.

**Spec:** `docs/superpowers/specs/2026-10-19-side-notch-ios-modularization-design.md`

## Global Constraints
- Target platform: iOS 17.0+
- Bundle identifier: `com.sidenotch.app`
- Language version: Swift 5.9 / 6.0
- Required background modes: `audio`, `fetch`, `processing`
- Zero placeholders or TODOs in any file.

---

### Task 1: Data Models & Bezel Shape

**Files:**
- Create: `SideNotch/Models/NotchMetric.swift`
- Create: `SideNotch/Models/NotchState.swift`
- Create: `SideNotch/Shapes/RightBezelLiquidShape.swift`

**Interfaces:**
- Produces:
  - `struct NotchMetric: Identifiable, Sendable` (properties: `id`, `name`, `percentage`, `accentColor`, `iconType: IconType`)
  - `enum NotchState: String, CaseIterable, Sendable` (`.dormant`, `.glance`, `.detachedGear`, `.expandedCard`)
  - `struct RightBezelLiquidShape: Shape` (parameters: `cornerRadius`, `filletRadius`, outputs `Path` with concave fillets)

- [ ] **Step 1: Create `SideNotch/Models/NotchMetric.swift`**
```swift
import SwiftUI

public struct NotchMetric: Identifiable, Sendable {
    public let id: UUID
    public let name: String
    public let percentage: Double // 0.0 to 1.0
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

- [ ] **Step 2: Create `SideNotch/Models/NotchState.swift`**
```swift
import Foundation

public enum NotchState: String, CaseIterable, Sendable {
    case dormant       // Thin bezel lip (8pt width)
    case glance        // Standard 3-gauge pill (58pt width)
    case detachedGear  // Pill + detached floating Settings bubble
    case expandedCard  // Full quick-action Bento telemetry card
}
```

- [ ] **Step 3: Create `SideNotch/Shapes/RightBezelLiquidShape.swift`**
```swift
import SwiftUI

/// Draws a vertical pill flush against the right edge (`maxX`) with smooth concave entry/exit curves.
public struct RightBezelLiquidShape: Shape {
    public var cornerRadius: CGFloat = 24
    public var filletRadius: CGFloat = 18
    
    public init(cornerRadius: CGFloat = 24, filletRadius: CGFloat = 18) {
        self.cornerRadius = cornerRadius
        self.filletRadius = filletRadius
    }
    
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let maxX = rect.maxX
        let minX = rect.minX
        let minY = rect.minY + filletRadius
        let maxY = rect.maxY - filletRadius
        
        // Start at top-right bezel above the top fillet
        path.move(to: CGPoint(x: maxX, y: rect.minY))
        
        // 1. Top Concave Fillet (Curves inward from the right bezel)
        path.addQuadCurve(
            to: CGPoint(x: maxX - filletRadius, y: minY),
            control: CGPoint(x: maxX, y: minY)
        )
        
        // Top horizontal bridge to inner left corner
        path.addLine(to: CGPoint(x: minX + cornerRadius, y: minY))
        
        // 2. Top-Left Convex Pill Corner
        path.addQuadCurve(
            to: CGPoint(x: minX, y: minY + cornerRadius),
            control: CGPoint(x: minX, y: minY)
        )
        
        // Left vertical inner edge
        path.addLine(to: CGPoint(x: minX, y: maxY - cornerRadius))
        
        // 3. Bottom-Left Convex Pill Corner
        path.addQuadCurve(
            to: CGPoint(x: minX + cornerRadius, y: maxY),
            control: CGPoint(x: minX, y: maxY)
        )
        
        // Bottom horizontal bridge toward right bezel
        path.addLine(to: CGPoint(x: maxX - filletRadius, y: maxY))
        
        // 4. Bottom Concave Fillet (Curves back down flush into the right bezel)
        path.addQuadCurve(
            to: CGPoint(x: maxX, y: rect.maxY),
            control: CGPoint(x: maxX, y: maxY)
        )
        
        path.closeSubpath()
        return path
    }
}
```

- [ ] **Step 4: Commit Task 1 files**
```bash
git add SideNotch/Models/ SideNotch/Shapes/
git commit -m "feat: add NotchMetric, NotchState models and RightBezelLiquidShape"
```

---

### Task 2: Granular UI Components & Overlays

**Files:**
- Create: `SideNotch/Views/Components/CustomMetricGlyph.swift`
- Create: `SideNotch/Views/Components/CircularGaugeItem.swift`
- Create: `SideNotch/Views/Components/ControlPillButton.swift`
- Create: `SideNotch/Views/Overlays/ExpandedBentoOverlay.swift`

**Interfaces:**
- Consumes: `NotchMetric`, `NotchMetric.IconType`
- Produces:
  - `struct CustomMetricGlyph: View`
  - `struct CircularGaugeItem: View`
  - `struct ControlPillButton: View`
  - `struct ExpandedBentoOverlay: View`

- [ ] **Step 1: Create `SideNotch/Views/Components/CustomMetricGlyph.swift`**
```swift
import SwiftUI

public struct CustomMetricGlyph: View {
    public let type: NotchMetric.IconType
    
    public init(type: NotchMetric.IconType) {
        self.type = type
    }
    
    public var body: some View {
        switch type {
        case .claudeSpark:
            ZStack {
                ForEach(0..<6, id: \.self) { i in
                    Capsule()
                        .fill(Color.white)
                        .frame(width: 1.6, height: 13)
                        .rotationEffect(.degrees(Double(i) * 30))
                }
            }
        case .openAISpiral:
            Image(systemName: "hurricane")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white)
        case .perplexityCrystal:
            ZStack {
                Image(systemName: "sparkles")
                Image(systemName: "asterisk")
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundStyle(.white)
        }
    }
}
```

- [ ] **Step 2: Create `SideNotch/Views/Components/CircularGaugeItem.swift`**
```swift
import SwiftUI

public struct CircularGaugeItem: View {
    public let metric: NotchMetric
    
    public init(metric: NotchMetric) {
        self.metric = metric
    }
    
    public var body: some View {
        VStack(spacing: 4) {
            ZStack {
                // Dark background track
                Circle()
                    .stroke(Color(white: 0.16), lineWidth: 3.2)
                    .frame(width: 34, height: 34)
                
                // Active Neon Progress Arc
                Circle()
                    .trim(from: 0, to: metric.percentage)
                    .stroke(
                        metric.accentColor,
                        style: StrokeStyle(lineWidth: 3.2, lineCap: .round)
                    )
                    .frame(width: 34, height: 34)
                    .rotationEffect(.degrees(-90))
                    .shadow(color: metric.accentColor.opacity(0.45), radius: 3, x: 0, y: 0)
                
                // Center Icon
                CustomMetricGlyph(type: metric.iconType)
            }
            
            // Percentage Label
            Text("\(Int(metric.percentage * 100))%")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.92))
        }
    }
}
```

- [ ] **Step 3: Create `SideNotch/Views/Components/ControlPillButton.swift`**
```swift
import SwiftUI

public struct ControlPillButton: View {
    public let title: String
    public let action: () -> Void
    
    public init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Capsule().fill(.black.opacity(0.75)))
                .overlay(Capsule().stroke(.white.opacity(0.2), lineWidth: 0.8))
        }
    }
}
```

- [ ] **Step 4: Create `SideNotch/Views/Overlays/ExpandedBentoOverlay.swift`**
```swift
import SwiftUI

public struct ExpandedBentoOverlay: View {
    public let metrics: [NotchMetric]
    public let onClose: () -> Void
    
    public init(metrics: [NotchMetric], onClose: @escaping () -> Void) {
        self.metrics = metrics
        self.onClose = onClose
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("LIVE TELEMETRY")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.5))
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            
            ForEach(metrics) { item in
                HStack(spacing: 10) {
                    Circle()
                        .fill(item.accentColor)
                        .frame(width: 8, height: 8)
                    Text(item.name)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.white)
                    Spacer()
                    Text("\(Int(item.percentage * 100))%")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundStyle(item.accentColor)
                }
            }
        }
        .padding(16)
        .frame(width: 210)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.ultraThinMaterial)
                .environment(\.colorScheme, .dark)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.14), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.45), radius: 20, x: -8, y: 10)
    }
}
```

- [ ] **Step 5: Commit Task 2 files**
```bash
git add SideNotch/Views/Components/ SideNotch/Views/Overlays/
git commit -m "feat: add micro-widgets CustomMetricGlyph, CircularGaugeItem, ControlPillButton, ExpandedBentoOverlay"
```

---

### Task 3: State & Background PiP Managers

**Files:**
- Create: `SideNotch/Managers/SideNotchStateManager.swift`
- Create: `SideNotch/Managers/SideNotchPiPManager.swift`

**Interfaces:**
- Consumes: `NotchState`, `NotchMetric`
- Produces:
  - `class SideNotchStateManager: ObservableObject` (`static let shared`, properties: `state`, `gearSeparation`, `metrics`, methods: `toggleNotch()`, `cycleState()`)
  - `class SideNotchPiPManager: NSObject, ObservableObject, AVPictureInPictureControllerDelegate` (`static let shared`, `setupPiP(with:)`, `togglePiP()`, `isPiPActive`)

- [ ] **Step 1: Create `SideNotch/Managers/SideNotchStateManager.swift`**
```swift
import SwiftUI
import Combine

@MainActor
public final class SideNotchStateManager: ObservableObject {
    public static let shared = SideNotchStateManager()
    
    @Published public var state: NotchState = .glance
    @Published public var gearSeparation: CGFloat = 0
    @Published public var metrics: [NotchMetric] = [
        NotchMetric(name: "Claude Quota", percentage: 0.73, accentColor: Color(red: 1.0, green: 0.34, blue: 0.13), iconType: .claudeSpark),
        NotchMetric(name: "OpenAI Credits", percentage: 0.21, accentColor: Color(red: 0.0, green: 0.90, blue: 0.46), iconType: .openAISpiral),
        NotchMetric(name: "Perplexity API", percentage: 0.52, accentColor: Color(red: 0.95, green: 0.92, blue: 0.0), iconType: .perplexityCrystal)
    ]
    
    public init() {}
    
    public func toggleNotch() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
            if state == .dormant {
                state = .glance
                gearSeparation = 0
            } else {
                state = .dormant
                gearSeparation = 0
            }
        }
        
        // If PiP is active, coordinate PiP toggle
        if SideNotchPiPManager.shared.isPiPActive {
            SideNotchPiPManager.shared.togglePiP()
        }
    }
    
    public func setGearDetached(_ detached: Bool) {
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
    
    public func toggleExpandedCard() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            state = (state == .expandedCard) ? .glance : .expandedCard
        }
    }
}
```

- [ ] **Step 2: Create `SideNotch/Managers/SideNotchPiPManager.swift`**
```swift
import UIKit
import AVKit
import AVFoundation
import SwiftUI
import Combine

@MainActor
public final class SideNotchPiPManager: NSObject, ObservableObject, AVPictureInPictureControllerDelegate {
    public static let shared = SideNotchPiPManager()
    
    @Published public private(set) var isPiPActive: Bool = false
    private var pipController: AVPictureInPictureController?
    
    public override init() {
        super.init()
        configureAudioSession()
    }
    
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("SideNotchPiPManager: Failed to configure audio session: \(error)")
        }
    }
    
    public func setupPiP(with sourceView: UIView) {
        guard AVPictureInPictureController.isPictureInPictureSupported() else {
            print("SideNotchPiPManager: PiP is not supported on this device.")
            return
        }
        
        let pipCallVC = AVPictureInPictureVideoCallViewController()
        pipCallVC.preferredContentSize = CGSize(width: 68, height: 280) // Slim vertical edge strip
        
        let hostingController = UIHostingController(rootView: SideLiquidNotchView())
        hostingController.view.backgroundColor = .clear
        hostingController.view.frame = pipCallVC.view.bounds
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        pipCallVC.addChild(hostingController)
        pipCallVC.view.addSubview(hostingController.view)
        hostingController.didMove(toParent: pipCallVC)
        
        let contentSource = AVPictureInPictureController.ContentSource(
            activeVideoCallSourceView: sourceView,
            contentViewController: pipCallVC
        )
        
        pipController = AVPictureInPictureController(contentSource: contentSource)
        pipController?.canStartPictureInPictureAutomaticallyFromInline = true
        pipController?.delegate = self
    }
    
    public func togglePiP() {
        guard let pip = pipController else { return }
        if pip.isPictureInPictureActive {
            pip.stopPictureInPicture()
        } else {
            pip.startPictureInPicture()
        }
    }
    
    public func startPiP() {
        pipController?.startPictureInPicture()
    }
    
    public func stopPiP() {
        pipController?.stopPictureInPicture()
    }
    
    // MARK: - AVPictureInPictureControllerDelegate
    
    public func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        isPiPActive = true
    }
    
    public func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        isPiPActive = false
    }
}
```

- [ ] **Step 3: Commit Task 3 files**
```bash
git add SideNotch/Managers/
git commit -m "feat: add SideNotchStateManager and SideNotchPiPManager"
```

---

### Task 4: Main Notch Views & Root Views

**Files:**
- Create: `SideNotch/Views/SideLiquidNotchView.swift`
- Create: `SideNotch/Views/WallpaperMockupBackground.swift`
- Create: `SideNotch/Views/ContentView.swift`
- Create: `SideNotch/App/SideNotchApp.swift`

**Interfaces:**
- Consumes: `SideNotchStateManager`, `SideNotchPiPManager`, `RightBezelLiquidShape`, `CustomMetricGlyph`, `CircularGaugeItem`, `ControlPillButton`, `ExpandedBentoOverlay`
- Produces:
  - `struct SideLiquidNotchView: View`
  - `struct WallpaperMockupBackground: View`
  - `struct ContentView: View`
  - `struct SideNotchApp: App`

- [ ] **Step 1: Create `SideNotch/Views/SideLiquidNotchView.swift`**
```swift
import SwiftUI
import UIKit

public struct SideLiquidNotchView: View {
    @ObservedObject private var stateManager = SideNotchStateManager.shared
    @State private var dragOffset: CGSize = .zero
    
    // Haptic generators
    private let impactRigid = UIImpactFeedbackGenerator(style: .rigid)
    private let impactSoft = UIImpactFeedbackGenerator(style: .soft)
    private let selectionFeedback = UISelectionFeedbackGenerator()
    
    public init() {}
    
    public var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .topTrailing) {
                // RIGHT-EDGE HARDWARE POWER BUTTON ANCHOR (~32% down from top on iPhone 16 Pro Max)
                ZStack(alignment: .topTrailing) {
                    
                    // LAYER A: Liquid Black Metaball Background (Canvas with AlphaThreshold + Blur)
                    Canvas { context, size in
                        context.addFilter(.alphaThreshold(min: 0.5, color: .black))
                        context.addFilter(.blur(radius: 8))
                        
                        context.drawLayer { ctx in
                            // 1. Main Bezel Pill
                            if let mainPill = ctx.resolveSymbol(id: "MainPill") {
                                ctx.draw(mainPill, at: CGPoint(x: size.width / 2, y: size.height / 2))
                            }
                            // 2. Detaching Settings Gear Bubble
                            if let gearNode = ctx.resolveSymbol(id: "GearNode") {
                                ctx.draw(gearNode, at: CGPoint(x: size.width / 2, y: size.height / 2))
                            }
                        }
                    } symbols: {
                        // Symbol 1: Main Bezel Pill
                        RightBezelLiquidShape(cornerRadius: 24, filletRadius: 18)
                            .fill(.black)
                            .frame(
                                width: pillWidth,
                                height: pillHeight
                            )
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                            .tag("MainPill")
                        
                        // Symbol 2: Detaching Settings Circle at Bottom
                        Circle()
                            .fill(.black)
                            .frame(width: 38, height: 38)
                            .offset(x: stateManager.state == .dormant ? 35 : -10, y: 222 + stateManager.gearSeparation)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                            .tag("GearNode")
                    }
                    .frame(width: 260, height: 340)
                    .allowsHitTesting(false)
                    
                    // LAYER B: Crisp Foreground Content (Gauges & Settings Icon)
                    if stateManager.state != .dormant {
                        VStack(spacing: 16) {
                            ForEach(stateManager.metrics) { metric in
                                CircularGaugeItem(metric: metric)
                                    .onTapGesture {
                                        selectionFeedback.selectionChanged()
                                        stateManager.toggleExpandedCard()
                                    }
                            }
                        }
                        .frame(width: 54)
                        .padding(.top, 26)
                        .padding(.trailing, 2)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                        
                        // Detached Settings Gear Button
                        Button {
                            impactRigid.impactOccurred()
                            stateManager.setGearDetached(stateManager.state != .detachedGear)
                        } label: {
                            Image(systemName: "gearshape")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 38, height: 38)
                                .rotationEffect(.degrees(Double(stateManager.gearSeparation) * 3))
                        }
                        .offset(x: -10, y: 222 + stateManager.gearSeparation)
                        .opacity(stateManager.gearSeparation > 8 ? 1.0 : 0.0)
                        
                        // Subtle bottom curved accent arc when gear is tucked inside
                        if stateManager.gearSeparation <= 8 {
                            Circle()
                                .trim(from: 0.55, to: 0.78)
                                .stroke(Color.black, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                                .frame(width: 28, height: 28)
                                .offset(x: -6, y: 226)
                        }
                    }
                    
                    // LAYER C: Expanded Bento Card Overlay
                    if stateManager.state == .expandedCard {
                        ExpandedBentoOverlay(metrics: stateManager.metrics) {
                            impactSoft.impactOccurred()
                            stateManager.toggleExpandedCard()
                        }
                        .offset(x: -68, y: 18)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.85, anchor: .trailing).combined(with: .opacity),
                            removal: .scale(scale: 0.9, anchor: .trailing).combined(with: .opacity)
                        ))
                    }
                }
                .offset(y: geo.size.height * 0.24) // Aligned with physical Power Button
                .gesture(
                    DragGesture(minimumDistance: 5)
                        .onChanged { value in
                            if value.translation.height > 0 {
                                stateManager.gearSeparation = min(40, value.translation.height * 0.6)
                            }
                        }
                        .onEnded { value in
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                if value.translation.width < -45 {
                                    impactRigid.impactOccurred()
                                    stateManager.state = (stateManager.state == .dormant) ? .glance : .expandedCard
                                } else if value.translation.width > 45 {
                                    impactSoft.impactOccurred()
                                    stateManager.state = (stateManager.state == .expandedCard) ? .glance : .dormant
                                    stateManager.gearSeparation = 0
                                } else if value.translation.height > 25 {
                                    selectionFeedback.selectionChanged()
                                    stateManager.setGearDetached(true)
                                } else if value.translation.height < -20 {
                                    selectionFeedback.selectionChanged()
                                    stateManager.setGearDetached(false)
                                }
                            }
                        }
                )
            }
        }
    }
    
    private var pillWidth: CGFloat {
        switch stateManager.state {
        case .dormant: return 8
        case .glance, .detachedGear, .expandedCard: return 58
        }
    }
    
    private var pillHeight: CGFloat {
        switch stateManager.state {
        case .dormant: return 110
        case .glance, .detachedGear, .expandedCard: return 240
        }
    }
}
```

- [ ] **Step 2: Create `SideNotch/Views/WallpaperMockupBackground.swift`**
```swift
import SwiftUI

public struct WallpaperMockupBackground: View {
    @ObservedObject private var stateManager = SideNotchStateManager.shared
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Gradient matching reference wallpaper
            LinearGradient(
                colors: [
                    Color(red: 0.98, green: 0.55, blue: 0.45),
                    Color(red: 0.72, green: 0.75, blue: 0.96),
                    Color(red: 0.85, green: 0.78, blue: 0.75)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Bottom Floating Control Bar to Test States Easily
            VStack {
                Spacer()
                HStack(spacing: 12) {
                    ControlPillButton(title: "Bezel Peek") {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                            stateManager.state = .dormant
                            stateManager.gearSeparation = 0
                        }
                    }
                    ControlPillButton(title: "Glance (Left Phone)") {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                            stateManager.state = .glance
                            stateManager.gearSeparation = 0
                        }
                    }
                    ControlPillButton(title: "Pop Gear (Right Phone)") {
                        stateManager.setGearDetached(true)
                    }
                }
                .padding(.bottom, 50)
            }
        }
    }
}
```

- [ ] **Step 3: Create `SideNotch/Views/ContentView.swift`**
```swift
import SwiftUI
import UIKit

public struct ContentView: View {
    public init() {}
    
    public var body: some View {
        ZStack {
            WallpaperMockupBackground()
            SideLiquidNotchView()
            
            // Background PiP anchor source view
            PiPAnchorView { sourceView in
                SideNotchPiPManager.shared.setupPiP(with: sourceView)
            }
            .frame(width: 1, height: 1)
            .opacity(0.01)
            .allowsHitTesting(false)
        }
        .ignoresSafeArea()
    }
}

private struct PiPAnchorView: UIViewRepresentable {
    let onSetup: (UIView) -> Void
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        view.backgroundColor = .clear
        DispatchQueue.main.async {
            onSetup(view)
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
```

- [ ] **Step 4: Create `SideNotch/App/SideNotchApp.swift`**
```swift
import SwiftUI

@main
struct SideNotchApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

- [ ] **Step 5: Commit Task 4 files**
```bash
git add SideNotch/Views/ SideNotch/App/
git commit -m "feat: add SideLiquidNotchView, WallpaperMockupBackground, ContentView, and SideNotchApp entry point"
```

---

### Task 5: AppIntents & Action Button Integration

**Files:**
- Create: `SideNotch/Intents/ToggleNotchIntent.swift`
- Create: `SideNotch/Intents/SideNotchShortcutsProvider.swift`

**Interfaces:**
- Consumes: `SideNotchStateManager`
- Produces:
  - `struct ToggleNotchIntent: AppIntent`
  - `struct SideNotchShortcutsProvider: AppShortcutsProvider`

- [ ] **Step 1: Create `SideNotch/Intents/ToggleNotchIntent.swift`**
```swift
import AppIntents

public struct ToggleNotchIntent: AppIntent {
    public static var title: LocalizedStringResource = "Toggle Side Notch"
    public static var description = IntentDescription("Toggles the Side Notch display between dormant and active glance states, or triggers the background overlay.")
    public static var openAppWhenRun: Bool = false
    
    public init() {}
    
    @MainActor
    public func perform() async throws -> some IntentResult {
        SideNotchStateManager.shared.toggleNotch()
        return .result()
    }
}
```

- [ ] **Step 2: Create `SideNotch/Intents/SideNotchShortcutsProvider.swift`**
```swift
import AppIntents

public struct SideNotchShortcutsProvider: AppShortcutsProvider {
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
```

- [ ] **Step 3: Commit Task 5 files**
```bash
git add SideNotch/Intents/
git commit -m "feat: add ToggleNotchIntent and SideNotchShortcutsProvider for Action Button support"
```

---

### Task 6: Resources, Assets & Info.plist

**Files:**
- Create: `SideNotch/Resources/Info.plist`
- Create: `SideNotch/Resources/Assets.xcassets/Contents.json`
- Create: `SideNotch/Resources/Assets.xcassets/AppIcon.appiconset/Contents.json`
- Create: `SideNotch/Resources/Assets.xcassets/AccentColor.colorset/Contents.json`

**Interfaces:**
- Produces:
  - `Info.plist` with `UIBackgroundModes` containing `audio`, `fetch`, `processing`
  - Valid Asset Catalogs for app build

- [ ] **Step 1: Create `SideNotch/Resources/Info.plist`**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>$(DEVELOPMENT_LANGUAGE)</string>
	<key>CFBundleExecutable</key>
	<string>$(EXECUTABLE_NAME)</string>
	<key>CFBundleIdentifier</key>
	<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>$(PRODUCT_NAME)</string>
	<key>CFBundlePackageType</key>
	<string>$(PRODUCT_BUNDLE_PACKAGE_TYPE)</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>CFBundleVersion</key>
	<string>1</string>
	<key>LSRequiresIPhoneOS</key>
	<true/>
	<key>UIBackgroundModes</key>
	<array>
		<string>audio</string>
		<string>fetch</string>
		<string>processing</string>
	</array>
	<key>UILaunchScreen</key>
	<dict/>
	<key>UIRequiredDeviceCapabilities</key>
	<array>
		<string>arm64</string>
	</array>
	<key>UISupportedInterfaceOrientations</key>
	<array>
		<string>UIInterfaceOrientationPortrait</string>
	</array>
</dict>
</plist>
```

- [ ] **Step 2: Create Asset Catalogs**
Create `SideNotch/Resources/Assets.xcassets/Contents.json`:
```json
{
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
```

Create `SideNotch/Resources/Assets.xcassets/AppIcon.appiconset/Contents.json`:
```json
{
  "images" : [
    {
      "idiom" : "universal",
      "platform" : "ios",
      "size" : "1024x1024"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
```

Create `SideNotch/Resources/Assets.xcassets/AccentColor.colorset/Contents.json`:
```json
{
  "colors" : [
    {
      "idiom" : "universal"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
```

- [ ] **Step 3: Commit Task 6 files**
```bash
git add SideNotch/Resources/
git commit -m "feat: add Info.plist with UIBackgroundModes and Assets.xcassets"
```

---

### Task 7: Native Xcode Project & Verification

**Files:**
- Create: `SideNotch.xcodeproj/project.pbxproj`
- Create: `Package.swift`

- [ ] **Step 1: Create `SideNotch.xcodeproj/project.pbxproj`**
Generate valid standard PBX project with UUIDs linking all source files, build phases, frameworks (`AVKit`, `AVFoundation`, `Combine`), and configurations for target `SideNotch` at iOS 17.0.

- [ ] **Step 2: Create `Package.swift`**
Create modern SwiftPM manifest referencing the `SideNotch` target for platform cross-checks.

- [ ] **Step 3: Verify All File References & Project Integrity**
Run PowerShell script to:
1. Verify all expected files exist.
2. Verify all references in `project.pbxproj` match actual file paths.
3. Verify `Info.plist` XML validity and `UIBackgroundModes` array.

- [ ] **Step 4: Commit Task 7 files**
```bash
git add SideNotch.xcodeproj/ Package.swift
git commit -m "feat: add native Xcode project and Package.swift manifest"
```
