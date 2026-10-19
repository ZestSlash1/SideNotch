import SwiftUI

/// Adds a 0.5pt subtle specular light reflection stroke along the bezel liquid shape,
/// giving the authentic physical illusion of ambient light catching the glass fillet.
public struct SpecularRimOverlay: View {
    public let orientation: BezelOrientation
    public let cornerRadius: CGFloat
    public let filletRadius: CGFloat
    
    public init(
        orientation: BezelOrientation = .right,
        cornerRadius: CGFloat = 24,
        filletRadius: CGFloat = 18
    ) {
        self.orientation = orientation
        self.cornerRadius = cornerRadius
        self.filletRadius = filletRadius
    }
    
    public var body: some View {
        BezelLiquidShape(
            orientation: orientation,
            cornerRadius: cornerRadius,
            filletRadius: filletRadius
        )
        .stroke(
            LinearGradient(
                colors: [
                    Color.white.opacity(0.35),
                    Color.white.opacity(0.12),
                    Color.clear
                ],
                startPoint: orientation == .right ? .topTrailing : .topLeading,
                endPoint: orientation == .right ? .bottomLeading : .bottomTrailing
            ),
            lineWidth: 0.6
        )
        .allowsHitTesting(false)
    }
}
