import SwiftUI

public struct NotchMetric: Identifiable, Sendable {
    public let id: UUID
    public let name: String
    public let percentage: Double // 0.0 to 1.0
    public let accentColor: Color
    public let iconType: IconType
    
    public enum IconType: Sendable {
        case claudeSpark
        case openAISpiral
        case perplexityCrystal
    }
    
    public init(
        id: UUID = UUID(),
        name: String,
        percentage: Double,
        accentColor: Color,
        iconType: IconType
    ) {
        self.id = id
        self.name = name
        self.percentage = percentage
        self.accentColor = accentColor
        self.iconType = iconType
    }
}
