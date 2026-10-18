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
