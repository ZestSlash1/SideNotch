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
