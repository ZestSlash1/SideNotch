import SwiftUI

public struct NotchAppItem: Identifiable, Codable, Sendable, Equatable {
    public var id: UUID
    public var name: String
    public var category: AppCategory
    public var iconSymbol: String
    public var accentHexColor: String
    public var progress: Double // 0.0 to 1.0
    public var primaryLabel: String
    public var secondaryPreview: String
    public var urlScheme: String?
    public var isEnabled: Bool
    public var quickActions: [AppQuickAction]
    
    public init(
        id: UUID = UUID(),
        name: String,
        category: AppCategory,
        iconSymbol: String,
        accentHexColor: String,
        progress: Double,
        primaryLabel: String,
        secondaryPreview: String,
        urlScheme: String? = nil,
        isEnabled: Bool = true,
        quickActions: [AppQuickAction] = []
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.iconSymbol = iconSymbol
        self.accentHexColor = accentHexColor
        self.progress = progress
        self.primaryLabel = primaryLabel
        self.secondaryPreview = secondaryPreview
        self.urlScheme = urlScheme
        self.isEnabled = isEnabled
        self.quickActions = quickActions
    }
    
    public var color: Color {
        Color(hex: accentHexColor)
    }
    
    public enum AppCategory: String, Codable, Sendable, CaseIterable {
        case media
        case ai
        case dev
        case social
        case delivery
        case system
        case custom
        
        public var title: String {
            switch self {
            case .media: return "Music & Media"
            case .ai: return "AI & Intelligence"
            case .dev: return "Developer"
            case .social: return "Social & Comms"
            case .delivery: return "Delivery & Rides"
            case .system: return "Hardware & System"
            case .custom: return "Custom Apps"
            }
        }
    }
}

public struct AppQuickAction: Identifiable, Codable, Sendable, Equatable {
    public var id: UUID
    public var title: String
    public var iconSymbol: String
    public var actionUrl: String?
    
    public init(
        id: UUID = UUID(),
        title: String,
        iconSymbol: String,
        actionUrl: String? = nil
    ) {
        self.id = id
        self.title = title
        self.iconSymbol = iconSymbol
        self.actionUrl = actionUrl
    }
}

// Hex color parser helper
extension Color {
    public init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 128, 128, 128)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
