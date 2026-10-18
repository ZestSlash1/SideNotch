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
