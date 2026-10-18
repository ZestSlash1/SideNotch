import Foundation

public enum NotchState: String, CaseIterable, Sendable {
    case dormant       // Thin bezel lip (8pt width)
    case glance        // Standard 3-gauge pill (58pt width)
    case detachedGear  // Pill + detached floating Settings bubble
    case expandedCard  // Full quick-action Bento telemetry card
}
