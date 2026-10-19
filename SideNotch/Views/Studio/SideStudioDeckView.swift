import SwiftUI

public struct SideStudioDeckView: View {
    @ObservedObject private var studioManager = SideNotchStudioManager.shared
    @State private var showingCreatorSheet: Bool = false
    @State private var showingCalibratorSheet: Bool = false
    @State private var showingActionButtonSheet: Bool = false
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 12) {
            // Top Row: Pinned Apps Mini-Dock
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(studioManager.apps) { app in
                        Button {
                            SideNotchHapticsEngine.shared.playSelectionTick()
                            studioManager.toggleExpandedCard(for: app)
                        } label: {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(app.color)
                                    .frame(width: 8, height: 8)
                                Image(systemName: app.iconSymbol)
                                    .font(.system(size: 11, weight: .bold))
                                Text(app.name)
                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                            }
                            .foregroundStyle(app.isEnabled ? .white : .white.opacity(0.4))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(app.isEnabled ? Color.white.opacity(0.14) : Color.white.opacity(0.04))
                            )
                            .overlay(
                                Capsule()
                                    .stroke(app.isEnabled ? app.color.opacity(0.4) : Color.white.opacity(0.1), lineWidth: 0.8)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    
                    // Add Custom App Button
                    Button {
                        SideNotchHapticsEngine.shared.playSelectionTick()
                        showingCreatorSheet = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                                .font(.system(size: 12, weight: .bold))
                            Text("Add App")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(Color.blue.opacity(0.6)))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)
            }
            
            // Bottom Action Deck: Quick Test Controls + Hardware Action Button + Calibrate
            HStack(spacing: 8) {
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                        studioManager.state = (studioManager.state == .dormant) ? .glance : .dormant
                        studioManager.gearSeparation = 0
                    }
                    SideNotchHapticsEngine.shared.playSelectionTick()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: studioManager.state == .dormant ? "eye" : "eye.slash")
                        Text(studioManager.state == .dormant ? "Expand" : "Collapse")
                    }
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 9)
                    .background(Capsule().fill(Color.white.opacity(0.12)))
                }
                
                Button {
                    studioManager.setGearDetached(studioManager.state != .detachedGear)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "gearshape.fill")
                        Text(studioManager.state == .detachedGear ? "Snap" : "Pop")
                    }
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 9)
                    .background(Capsule().fill(Color.white.opacity(0.12)))
                }
                
                Spacer()
                
                // Hardware Action Button Quick Config
                Button {
                    SideNotchHapticsEngine.shared.playSelectionTick()
                    showingActionButtonSheet = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "button.programmable")
                            .font(.system(size: 11, weight: .bold))
                        Text("Action Button")
                    }
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 11)
                    .padding(.vertical, 9)
                    .background(
                        Capsule()
                            .fill(LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing))
                    )
                    .shadow(color: .orange.opacity(0.35), radius: 5, x: 0, y: 2)
                }
                
                Button {
                    SideNotchHapticsEngine.shared.playSelectionTick()
                    showingCalibratorSheet = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "slider.horizontal.3")
                        Text("Calibrate")
                    }
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 11)
                    .padding(.vertical, 9)
                    .background(
                        Capsule()
                            .fill(LinearGradient(colors: [.indigo, .purple], startPoint: .leading, endPoint: .trailing))
                    )
                    .shadow(color: .purple.opacity(0.4), radius: 6, x: 0, y: 2)
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.ultraThinMaterial)
                .environment(\.colorScheme, .dark)
                .shadow(color: .black.opacity(0.4), radius: 20, x: 0, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.15), lineWidth: 0.8)
        )
        .padding(.horizontal, 16)
        .sheet(isPresented: $showingCreatorSheet) {
            CustomAppCreatorView()
        }
        .sheet(isPresented: $showingCalibratorSheet) {
            NotchCalibratorView()
        }
        .sheet(isPresented: $showingActionButtonSheet) {
            ActionButtonGuideSheet()
        }
    }
}
