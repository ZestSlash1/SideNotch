import SwiftUI

public struct CustomAppCreatorView: View {
    @ObservedObject private var studioManager = SideNotchStudioManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var category: NotchAppItem.AppCategory = .custom
    @State private var iconSymbol: String = "app.badge.fill"
    @State private var selectedColorHex: String = "#3B82F6"
    @State private var progress: Double = 0.75
    @State private var primaryLabel: String = "Active"
    @State private var secondaryPreview: String = "App running in background"
    @State private var urlScheme: String = ""
    
    private let availableSymbols = [
        "app.badge.fill", "bolt.fill", "sparkles", "waveform", "antenna.radiowaves.left.and.right",
        "bubble.left.and.bubble.right.fill", "cart.fill", "car.fill", "flame.fill", "heart.fill",
        "chart.line.uptrend.xyaxis", "lock.fill", "shield.fill", "envelope.fill", "bell.fill",
        "clock.fill", "gamecontroller.fill", "headphones", "camera.fill", "music.note"
    ]
    
    private let presetHexColors = [
        "#3B82F6", "#10B981", "#F59E0B", "#EF4444", "#EC4899",
        "#8B5CF6", "#14B8A6", "#6366F1", "#F97316", "#06B6D4"
    ]
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            Form {
                Section("App Information") {
                    TextField("App Name (e.g. Notion, Discord)", text: $name)
                    
                    Picker("Category", selection: $category) {
                        ForEach(NotchAppItem.AppCategory.allCases, id: \.self) { cat in
                            Text(cat.title).tag(cat)
                        }
                    }
                    
                    TextField("URL Scheme (e.g. notion://, discord://)", text: $urlScheme)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                }
                
                Section("Live Status & Telemetry") {
                    HStack {
                        Text("Ring Value: \(Int(progress * 100))%")
                        Spacer()
                    }
                    Slider(value: $progress, in: 0...1, step: 0.05)
                    
                    TextField("Primary Label (e.g. 75%, Active, 5m)", text: $primaryLabel)
                    TextField("Secondary Preview Description", text: $secondaryPreview)
                }
                
                Section("Icon Symbol") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                        ForEach(availableSymbols, id: \.self) { symbol in
                            Button {
                                iconSymbol = symbol
                                SideNotchHapticsEngine.shared.playSelectionTick()
                            } label: {
                                Image(systemName: symbol)
                                    .font(.system(size: 18))
                                    .frame(width: 44, height: 44)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(iconSymbol == symbol ? Color(hex: selectedColorHex) : Color.white.opacity(0.08))
                                    )
                                    .foregroundStyle(iconSymbol == symbol ? .white : .primary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                Section("Neon Accent Color") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                        ForEach(presetHexColors, id: \.self) { hex in
                            Button {
                                selectedColorHex = hex
                                SideNotchHapticsEngine.shared.playSelectionTick()
                            } label: {
                                Circle()
                                    .fill(Color(hex: hex))
                                    .frame(width: 36, height: 36)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: selectedColorHex == hex ? 3 : 0)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Add Custom App")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add to Notch") {
                        saveApp()
                    }
                    .fontWeight(.bold)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
    
    private func saveApp() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let newApp = NotchAppItem(
            name: trimmedName,
            category: category,
            iconSymbol: iconSymbol,
            accentHexColor: selectedColorHex,
            progress: progress,
            primaryLabel: primaryLabel.isEmpty ? "\(Int(progress * 100))%" : primaryLabel,
            secondaryPreview: secondaryPreview.isEmpty ? "\(trimmedName) active in notch" : secondaryPreview,
            urlScheme: urlScheme.isEmpty ? nil : urlScheme,
            isEnabled: true,
            quickActions: [
                AppQuickAction(title: "Launch", iconSymbol: "arrow.up.forward.app")
            ]
        )
        studioManager.addCustomApp(newApp)
        dismiss()
    }
}
