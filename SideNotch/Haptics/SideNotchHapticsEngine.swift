import UIKit
import CoreHaptics

@MainActor
public final class SideNotchHapticsEngine: ObservableObject {
    public static let shared = SideNotchHapticsEngine()
    
    private var engine: CHHapticEngine?
    private let selectionFeedback = UISelectionFeedbackGenerator()
    private let rigidImpact = UIImpactFeedbackGenerator(style: .rigid)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let softImpact = UIImpactFeedbackGenerator(style: .soft)
    
    public init() {
        prepareHaptics()
    }
    
    public func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            engine = try CHHapticEngine()
            try engine?.start()
            engine?.resetHandler = { [weak self] in
                try? self?.engine?.start()
            }
        } catch {
            print("SideNotchHapticsEngine: CoreHaptics not supported or failed to start: \(error)")
        }
        
        selectionFeedback.prepare()
        rigidImpact.prepare()
        heavyImpact.prepare()
        softImpact.prepare()
    }
    
    /// Continuous fluid surface tension feedback while dragging
    public func playDragTension(distance: CGFloat) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics, let engine = engine else {
            if distance.truncatingRemainder(dividingBy: 12) < 2 {
                selectionFeedback.selectionChanged()
            }
            return
        }
        
        let intensity = Float(min(1.0, max(0.2, distance / 60.0)))
        let sharpness = Float(min(0.8, 0.2 + (distance / 80.0)))
        
        let intensityParam = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity)
        let sharpnessParam = CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
        
        let event = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [intensityParam, sharpnessParam],
            relativeTime: 0
        )
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            selectionFeedback.selectionChanged()
        }
    }
    
    /// Sharp, satisfying pop when the gear or node separates past the threshold
    public func playSurfaceTensionPop() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics, let engine = engine else {
            heavyImpact.impactOccurred()
            return
        }
        
        let event1 = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.9),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
            ],
            relativeTime: 0
        )
        let event2 = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
            ],
            relativeTime: 0.04
        )
        
        do {
            let pattern = try CHHapticPattern(events: [event1, event2], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            heavyImpact.impactOccurred()
        }
    }
    
    /// Dampened magnetic thud when the notch snaps back to the bezel
    public func playDockingSnap() {
        rigidImpact.impactOccurred()
    }
    
    /// Crisp selection tick when expanding Bento cards or switching apps
    public func playSelectionTick() {
        selectionFeedback.selectionChanged()
    }
    
    /// Quick action / app launch pulse
    public func playAppLaunchPulse() {
        heavyImpact.impactOccurred()
    }
}
