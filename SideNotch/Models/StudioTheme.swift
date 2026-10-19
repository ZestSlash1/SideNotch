import SwiftUI

public enum StudioTheme: String, Codable, Sendable, CaseIterable {
    case oledBlack
    case sunsetSilk
    case cupertinoAurora
    case titaniumMesh
    case deepSpace
    
    public var title: String {
        switch self {
        case .oledBlack: return "OLED Pure Black"
        case .sunsetSilk: return "Sunset Silk"
        case .cupertinoAurora: return "Cupertino Aurora"
        case .titaniumMesh: return "Titanium Dark"
        case .deepSpace: return "Deep Space"
        }
    }
    
    public var gradientColors: [Color] {
        switch self {
        case .oledBlack:
            return [Color.black, Color.black]
        case .sunsetSilk:
            return [
                Color(red: 0.98, green: 0.52, blue: 0.42),
                Color(red: 0.75, green: 0.70, blue: 0.95),
                Color(red: 0.88, green: 0.82, blue: 0.80)
            ]
        case .cupertinoAurora:
            return [
                Color(red: 0.12, green: 0.22, blue: 0.45),
                Color(red: 0.08, green: 0.42, blue: 0.48),
                Color(red: 0.05, green: 0.12, blue: 0.22)
            ]
        case .titaniumMesh:
            return [
                Color(white: 0.16),
                Color(white: 0.08),
                Color(white: 0.04)
            ]
        case .deepSpace:
            return [
                Color(red: 0.05, green: 0.02, blue: 0.15),
                Color(red: 0.15, green: 0.05, blue: 0.25),
                Color(red: 0.02, green: 0.01, blue: 0.06)
            ]
        }
    }
}
