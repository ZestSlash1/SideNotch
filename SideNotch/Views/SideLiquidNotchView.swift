import SwiftUI
import UIKit

public struct SideLiquidNotchView: View {
    @ObservedObject private var studioManager = SideNotchStudioManager.shared
    @State private var dragOffset: CGSize = .zero
    
    public init() {}
    
    public var body: some View {
        GeometryReader { geo in
            let notchYOffset = geo.size.height * studioManager.verticalPositionRatio
            let isRight = studioManager.orientation == .right
            let pillW = pillWidth
            let pillH = pillHeight
            
            ZStack(alignment: isRight ? .topTrailing : .topLeading) {
                // LAYER C: Expanded Bento Preview Card (App details + Quick Actions)
                if studioManager.state == .expandedCard, let selectedApp = studioManager.selectedApp {
                    ExpandedAppBentoCard(app: selectedApp) {
                        SideNotchHapticsEngine.shared.playSelectionTick()
                        studioManager.toggleExpandedCard()
                    }
                    .padding(isRight ? .trailing : .leading, pillW + 12)
                    .padding(.top, notchYOffset)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.9, anchor: isRight ? .trailing : .leading).combined(with: .opacity),
                        removal: .scale(scale: 0.95, anchor: isRight ? .trailing : .leading).combined(with: .opacity)
                    ))
                }
                
                // NOTCH HARDWARE ASSEMBLY
                ZStack(alignment: isRight ? .topTrailing : .topLeading) {
                    
                    // LAYER A: Liquid Black Metaball Canvas (Direct Path Fusion)
                    Canvas { context, size in
                        context.addFilter(.alphaThreshold(min: 0.5, color: .black))
                        context.addFilter(.blur(radius: 8))
                        
                        context.drawLayer { ctx in
                            // 1. Main Bezel Pill (Strictly flush against edge)
                            let pillX = isRight ? (size.width - pillW) : 0
                            let pillRect = CGRect(x: pillX, y: 0, width: pillW, height: pillH)
                            let pillPath = BezelLiquidShape(
                                orientation: studioManager.orientation,
                                cornerRadius: 24,
                                filletRadius: 18
                            ).path(in: pillRect)
                            ctx.fill(pillPath, with: .color(.black))
                            
                            // 2. Liquid Surface Tension Detaching Gear Node
                            if studioManager.state != .dormant {
                                let gearRadius: CGFloat = 19
                                let gearCenterX = isRight ? (size.width - pillW / 2) : (pillW / 2)
                                let gearCenterY = pillH - 20 + studioManager.gearSeparation
                                let gearRect = CGRect(
                                    x: gearCenterX - gearRadius,
                                    y: gearCenterY - gearRadius,
                                    width: gearRadius * 2,
                                    height: gearRadius * 2
                                )
                                ctx.fill(Path(ellipseIn: gearRect), with: .color(.black))
                            }
                        }
                    }
                    .frame(width: 140, height: 380)
                    .allowsHitTesting(false)
                    
                    // LAYER A.2: Specular Rim Lighting (Titanium Ambient Reflection)
                    let pillX = isRight ? (140 - pillW) : 0
                    SpecularRimOverlay(
                        orientation: studioManager.orientation,
                        cornerRadius: 24,
                        filletRadius: 18
                    )
                    .frame(width: pillW, height: pillH)
                    .offset(x: pillX)
                    .opacity(0.85)
                    
                    // LAYER B: Crisp Foreground Micro-Widgets (App Rings & Icons)
                    if studioManager.state != .dormant {
                        VStack(spacing: 14) {
                            ForEach(studioManager.activeApps.prefix(3)) { app in
                                UniversalAppGaugeItem(
                                    app: app,
                                    isSelected: studioManager.selectedAppId == app.id && studioManager.state == .expandedCard
                                )
                                .onTapGesture {
                                    studioManager.toggleExpandedCard(for: app)
                                }
                            }
                        }
                        .frame(width: pillW)
                        .padding(.top, 22)
                        .transition(.move(edge: isRight ? .trailing : .leading).combined(with: .opacity))
                        
                        // Detached Settings Gear Button
                        Button {
                            studioManager.setGearDetached(studioManager.state != .detachedGear)
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 38, height: 38)
                                .rotationEffect(.degrees(Double(studioManager.gearSeparation) * 3))
                        }
                        .frame(width: pillW)
                        .offset(y: pillH - 38 + studioManager.gearSeparation)
                        .opacity(studioManager.gearSeparation > 6 ? 1.0 : 0.0)
                        
                        // Subtle drag pull indicator
                        if studioManager.gearSeparation <= 6 {
                            Image(systemName: "chevron.compact.down")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white.opacity(0.35))
                                .frame(width: pillW)
                                .offset(y: pillH - 26)
                                .allowsHitTesting(false)
                        }
                    }
                }
                .frame(width: 140, height: 380, alignment: isRight ? .topTrailing : .topLeading)
                .offset(y: notchYOffset)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 4)
                        .onChanged { value in
                            // Elastic drag tension haptics
                            if value.translation.height > 0 {
                                studioManager.gearSeparation = min(42, value.translation.height * 0.6)
                                SideNotchHapticsEngine.shared.playDragTension(distance: studioManager.gearSeparation)
                            }
                        }
                        .onEnded { value in
                            let swipeOut = isRight ? (value.translation.width < -35) : (value.translation.width > 35)
                            let swipeIn = isRight ? (value.translation.width > 35) : (value.translation.width < -35)
                            
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                if swipeOut {
                                    SideNotchHapticsEngine.shared.playSelectionTick()
                                    studioManager.state = (studioManager.state == .dormant) ? .glance : .expandedCard
                                } else if swipeIn {
                                    SideNotchHapticsEngine.shared.playDockingSnap()
                                    studioManager.state = (studioManager.state == .expandedCard) ? .glance : .dormant
                                    studioManager.gearSeparation = 0
                                } else if value.translation.height > 20 {
                                    studioManager.setGearDetached(true)
                                } else if value.translation.height < -15 {
                                    studioManager.setGearDetached(false)
                                }
                            }
                        }
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: isRight ? .topTrailing : .topLeading)
        }
        .ignoresSafeArea()
    }
    
    private var pillWidth: CGFloat {
        switch studioManager.state {
        case .dormant: return 8
        case .glance, .detachedGear, .expandedCard: return studioManager.customPillWidth
        }
    }
    
    private var pillHeight: CGFloat {
        switch studioManager.state {
        case .dormant: return 110
        case .glance, .detachedGear, .expandedCard: return 250
        }
    }
}
