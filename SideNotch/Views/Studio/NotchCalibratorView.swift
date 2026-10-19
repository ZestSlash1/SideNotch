import SwiftUI

public struct NotchCalibratorView: View {
    @ObservedObject private var studioManager = SideNotchStudioManager.shared
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            Form {
                Section("Bezel Placement") {
                    Picker("Active Bezel Side", selection: $studioManager.orientation) {
                        ForEach(BezelOrientation.allCases, id: \.self) { side in
                            Text(side.title).tag(side)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Vertical Position")
                            Spacer()
                            Text("\(Int(studioManager.verticalPositionRatio * 100))%")
                                .font(.system(.body, design: .monospaced))
                                .foregroundStyle(.secondary)
                        }
                        
                        Slider(value: $studioManager.verticalPositionRatio, in: 0.15...0.65, step: 0.01) {
                            Text("Vertical Position")
                        } minimumValueLabel: {
                            Text("Top")
                                .font(.caption2)
                        } maximumValueLabel: {
                            Text("Bottom")
                                .font(.caption2)
                        }
                        
                        HStack(spacing: 8) {
                            Button("Power Button (26%)") {
                                studioManager.verticalPositionRatio = 0.26
                            }
                            .buttonStyle(.bordered)
                            .font(.caption)
                            
                            Button("Action Button (20%)") {
                                studioManager.verticalPositionRatio = 0.20
                            }
                            .buttonStyle(.bordered)
                            .font(.caption)
                        }
                    }
                }
                
                Section("Notch Dimensions") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Pill Width")
                            Spacer()
                            Text("\(Int(studioManager.customPillWidth)) pt")
                                .font(.system(.body, design: .monospaced))
                                .foregroundStyle(.secondary)
                        }
                        
                        Slider(value: $studioManager.customPillWidth, in: 50...70, step: 1) {
                            Text("Width")
                        }
                        
                        HStack(spacing: 8) {
                            Button("Slim (52pt)") { studioManager.customPillWidth = 52 }
                                .buttonStyle(.bordered).font(.caption)
                            Button("Standard (58pt)") { studioManager.customPillWidth = 58 }
                                .buttonStyle(.bordered).font(.caption)
                            Button("Wide (64pt)") { studioManager.customPillWidth = 64 }
                                .buttonStyle(.bordered).font(.caption)
                        }
                    }
                }
                
                Section("Themes & Backdrops") {
                    Picker("Theme Wallpaper", selection: $studioManager.activeTheme) {
                        ForEach(StudioTheme.allCases, id: \.self) { theme in
                            Text(theme.title).tag(theme)
                        }
                    }
                }
            }
            .navigationTitle("Notch Hardware Calibration")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
}
