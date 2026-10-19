import Foundation

public enum BezelOrientation: String, Codable, Sendable, CaseIterable {
    case right // Power button side
    case left  // Action button side
    
    public var title: String {
        switch self {
        case .right: return "Right Bezel (Power)"
        case .left: return "Left Bezel (Action)"
        }
    }
}
