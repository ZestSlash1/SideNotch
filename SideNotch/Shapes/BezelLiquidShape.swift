import SwiftUI

/// Draws an Apple-grade liquid pill flush against the physical bezel (Left or Right)
/// with G2 continuous concave entry/exit fillets curving directly into the frame.
public struct BezelLiquidShape: Shape {
    public var orientation: BezelOrientation
    public var cornerRadius: CGFloat
    public var filletRadius: CGFloat
    
    public init(
        orientation: BezelOrientation = .right,
        cornerRadius: CGFloat = 24,
        filletRadius: CGFloat = 18
    ) {
        self.orientation = orientation
        self.cornerRadius = cornerRadius
        self.filletRadius = filletRadius
    }
    
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        
        if orientation == .right {
            // RIGHT BEZEL: Flush against rect.maxX
            let maxX = rect.maxX
            let minX = rect.minX
            let minY = rect.minY + filletRadius
            let maxY = rect.maxY - filletRadius
            
            path.move(to: CGPoint(x: maxX, y: rect.minY))
            
            // 1. Top Concave Fillet into bezel
            path.addQuadCurve(
                to: CGPoint(x: maxX - filletRadius, y: minY),
                control: CGPoint(x: maxX, y: minY)
            )
            
            // Top bridge
            path.addLine(to: CGPoint(x: minX + cornerRadius, y: minY))
            
            // 2. Top-Left Convex Corner
            path.addQuadCurve(
                to: CGPoint(x: minX, y: minY + cornerRadius),
                control: CGPoint(x: minX, y: minY)
            )
            
            // Left vertical edge
            path.addLine(to: CGPoint(x: minX, y: maxY - cornerRadius))
            
            // 3. Bottom-Left Convex Corner
            path.addQuadCurve(
                to: CGPoint(x: minX + cornerRadius, y: maxY),
                control: CGPoint(x: minX, y: maxY)
            )
            
            // Bottom bridge
            path.addLine(to: CGPoint(x: maxX - filletRadius, y: maxY))
            
            // 4. Bottom Concave Fillet into bezel
            path.addQuadCurve(
                to: CGPoint(x: maxX, y: rect.maxY),
                control: CGPoint(x: maxX, y: maxY)
            )
            
            path.closeSubpath()
        } else {
            // LEFT BEZEL: Flush against rect.minX
            let minX = rect.minX
            let maxX = rect.maxX
            let minY = rect.minY + filletRadius
            let maxY = rect.maxY - filletRadius
            
            path.move(to: CGPoint(x: minX, y: rect.minY))
            
            // 1. Top Concave Fillet from left bezel
            path.addQuadCurve(
                to: CGPoint(x: minX + filletRadius, y: minY),
                control: CGPoint(x: minX, y: minY)
            )
            
            // Top bridge to outer right corner
            path.addLine(to: CGPoint(x: maxX - cornerRadius, y: minY))
            
            // 2. Top-Right Convex Corner
            path.addQuadCurve(
                to: CGPoint(x: maxX, y: minY + cornerRadius),
                control: CGPoint(x: maxX, y: minY)
            )
            
            // Right vertical edge
            path.addLine(to: CGPoint(x: maxX, y: maxY - cornerRadius))
            
            // 3. Bottom-Right Convex Corner
            path.addQuadCurve(
                to: CGPoint(x: maxX - cornerRadius, y: maxY),
                control: CGPoint(x: maxX, y: maxY)
            )
            
            // Bottom bridge to left fillet
            path.addLine(to: CGPoint(x: minX + filletRadius, y: maxY))
            
            // 4. Bottom Concave Fillet into left bezel
            path.addQuadCurve(
                to: CGPoint(x: minX, y: rect.maxY),
                control: CGPoint(x: minX, y: maxY)
            )
            
            path.closeSubpath()
        }
        
        return path
    }
}
