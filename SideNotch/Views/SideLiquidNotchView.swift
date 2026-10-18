import SwiftUI
import UIKit

public struct SideLiquidNotchView: View {
    @ObservedObject private var stateManager = SideNotchStateManager.shared
    
    // Haptic feedback generators
    private let impactRigid = UIImpactFeedbackGenerator(style: .rigid)
    private let impactSoft = UIImpactFeedbackGenerator(style: .soft)
    private let selectionFeedback = UISelectionFeedbackGenerator()
    
    public init() {}
    
    public var body: some View {
        GeometryReader { geo in
            let notchYOffset = geo.size.height * 0.26 // Aligned with physical Power button
            
            ZStack(alignment: .topTrailing) {
                // Expanded Bento card overlay (slides in to the left of the pill)
                if stateManager.state == .expandedCard {
                    ExpandedBentoOverlay(metrics: stateManager.metrics) {
                        impactSoft.impactOccurred()
                        stateManager.toggleExpandedCard()
                    }
                    .padding(.trailing, 68) // Sits just left of the 58pt pill
                    .padding(.top, notchYOffset + 10)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.9, anchor: .trailing).combined(with: .opacity),
                        removal: .scale(scale: 0.95, anchor: .trailing).combined(with: .opacity)
                    ))
                }
                
                // NOTCH ASSEMBLY (Strictly anchored flush to the screen's right bezel)
                ZStack(alignment: .topTrailing) {
                    
                    // LAYER A: Liquid Black Metaball Canvas (Direct path drawing for exact bezel contact)
                    Canvas { context, size in
                        context.addFilter(.alphaThreshold(min: 0.5, color: .black))
                        context.addFilter(.blur(radius: 8))
                        
                        context.drawLayer { ctx in
                            // 1. Main Bezel Pill (Mathematically flush with size.width / maxX)
                            let pillRect = CGRect(
                                x: size.width - pillWidth,
                                y: 0,
                                width: pillWidth,
                                height: pillHeight
                            )
                            let pillPath = RightBezelLiquidShape(cornerRadius: 24, filletRadius: 18).path(in: pillRect)
                            ctx.fill(pillPath, with: .color(.black))
                            
                            // 2. Detaching Liquid Settings Gear Bubble
                            if stateManager.state != .dormant {
                                let gearRadius: CGFloat = 19
                                let gearCenterX = size.width - (pillWidth / 2)
                                let gearCenterY = pillHeight - 20 + stateManager.gearSeparation
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
                    .frame(width: 140, height: 340)
                    .allowsHitTesting(false)
                    
                    // LAYER B: Crisp Foreground Content (Gauges & Icons)
                    if stateManager.state != .dormant {
                        // Vertical column of circular gauges
                        VStack(spacing: 16) {
                            ForEach(stateManager.metrics) { metric in
                                CircularGaugeItem(metric: metric)
                                    .onTapGesture {
                                        selectionFeedback.selectionChanged()
                                        stateManager.toggleExpandedCard()
                                    }
                            }
                        }
                        .frame(width: pillWidth)
                        .padding(.top, 24)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                        
                        // Detached Settings Gear Button
                        Button {
                            impactRigid.impactOccurred()
                            stateManager.setGearDetached(stateManager.state != .detachedGear)
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 38, height: 38)
                                .rotationEffect(.degrees(Double(stateManager.gearSeparation) * 3))
                        }
                        .frame(width: pillWidth)
                        .offset(y: pillHeight - 38 + stateManager.gearSeparation)
                        .opacity(stateManager.gearSeparation > 6 ? 1.0 : 0.0)
                        
                        // Subtle drag indicator when gear is docked inside pill
                        if stateManager.gearSeparation <= 6 {
                            Image(systemName: "chevron.compact.down")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white.opacity(0.35))
                                .frame(width: pillWidth)
                                .offset(y: pillHeight - 26)
                                .allowsHitTesting(false)
                        }
                    }
                }
                .frame(width: 140, height: 340, alignment: .topTrailing)
                .offset(y: notchYOffset)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 5)
                        .onChanged { value in
                            if value.translation.height > 0 {
                                stateManager.gearSeparation = min(40, value.translation.height * 0.6)
                            }
                        }
                        .onEnded { value in
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                if value.translation.width < -40 {
                                    // Swipe Left -> Expand to Bento card or wake from dormant
                                    impactRigid.impactOccurred()
                                    stateManager.state = (stateManager.state == .dormant) ? .glance : .expandedCard
                                } else if value.translation.width > 40 {
                                    // Swipe Right -> Collapse flush into bezel lip
                                    impactSoft.impactOccurred()
                                    stateManager.state = (stateManager.state == .expandedCard) ? .glance : .dormant
                                    stateManager.gearSeparation = 0
                                } else if value.translation.height > 20 {
                                    // Swipe Down -> Detach liquid gear bubble
                                    selectionFeedback.selectionChanged()
                                    stateManager.setGearDetached(true)
                                } else if value.translation.height < -15 {
                                    // Swipe Up -> Snap gear back into pill
                                    selectionFeedback.selectionChanged()
                                    stateManager.setGearDetached(false)
                                }
                            }
                        }
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        }
        .ignoresSafeArea()
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
