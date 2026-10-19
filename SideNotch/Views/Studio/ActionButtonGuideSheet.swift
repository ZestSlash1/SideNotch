import SwiftUI
import UIKit

/// Interactive visual guide and testing suite for mapping the iPhone Action Button
/// and Back Tap gestures directly to Side Notch.
public struct ActionButtonGuideSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var studioManager = SideNotchStudioManager.shared
    @State private var hasTestedHaptic: Bool = false
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Banner with Action Button Icon
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 64, height: 64)
                                .shadow(color: .orange.opacity(0.5), radius: 12)
                            
                            Image(systemName: "button.programmable")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        
                        Text("Action Button Quick-Peek")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        
                        Text("Trigger Side Notch instantly from any screen, game, or locked display.")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    .padding(.top, 10)
                    
                    // Card 1: iPhone 15 Pro / 16 / 16 Pro Action Button
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(spacing: 8) {
                            Image(systemName: "iphone.gen3")
                                .foregroundStyle(Color.orange)
                            Text("iPhone Action Button Setup")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            StepInstructionRow(number: "1", text: "Open iPhone **Settings** app.")
                            StepInstructionRow(number: "2", text: "Scroll down and tap **Action Button**.")
                            StepInstructionRow(number: "3", text: "Swipe across until you reach **Shortcut**.")
                            StepInstructionRow(number: "4", text: "Tap the selector, choose **SideNotch**, and select **Toggle Notch**.")
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.white.opacity(0.06))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.white.opacity(0.12), lineWidth: 0.8)
                    )
                    
                    // Card 2: Custom Shortcut (Instant Direct Launch)
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(spacing: 8) {
                            Image(systemName: "square.stack.3d.up.fill")
                                .foregroundStyle(Color.purple)
                            Text("Creating Shortcut in Shortcuts App")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            StepInstructionRow(number: "1", text: "Open Apple's **Shortcuts** app on your phone.")
                            StepInstructionRow(number: "2", text: "Tap **+** in the top right to create a new shortcut.")
                            StepInstructionRow(number: "3", text: "Tap **Add Action** → search **Open App** → pick **SideNotch** (or choose **SideNotch → Toggle Side Notch**).")
                            StepInstructionRow(number: "4", text: "Save the shortcut. You can now assign this directly to the Action Button or Home Screen!")
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.white.opacity(0.06))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.white.opacity(0.12), lineWidth: 0.8)
                    )
                    
                    // Card 3: Back Tap Alternative (For any iPhone)
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(spacing: 8) {
                            Image(systemName: "hand.tap.fill")
                                .foregroundStyle(Color.cyan)
                            Text("Back Tap Gesture (Any iPhone)")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            StepInstructionRow(number: "1", text: "Open **Settings** → **Accessibility** → **Touch**.")
                            StepInstructionRow(number: "2", text: "Scroll to bottom and tap **Back Tap**.")
                            StepInstructionRow(number: "3", text: "Choose **Double Tap** or **Triple Tap**.")
                            StepInstructionRow(number: "4", text: "Scroll to Shortcuts section and select **SideNotch** or your shortcut.")
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.white.opacity(0.06))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.white.opacity(0.12), lineWidth: 0.8)
                    )
                    
                    // Test Action Button / Jump to Settings
                    VStack(spacing: 12) {
                        Button {
                            SideNotchHapticsEngine.shared.playDockingSnap()
                            hasTestedHaptic = true
                            studioManager.state = .glance
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                dismiss()
                            }
                        } label: {
                            HStack {
                                Image(systemName: hasTestedHaptic ? "checkmark.circle.fill" : "play.fill")
                                Text(hasTestedHaptic ? "Action Button Triggered!" : "Test Action Button Launch")
                            }
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing))
                            )
                        }
                        
                        Button {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            HStack {
                                Image(systemName: "gearshape")
                                Text("Open iOS Settings")
                            }
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.85))
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color.white.opacity(0.08))
                            )
                        }
                    }
                    .padding(.top, 6)
                }
                .padding(20)
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Hardware Action")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                }
            }
        }
    }
}

private struct StepInstructionRow: View {
    let number: String
    let text: LocalizedStringKey
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text(number)
                .font(.system(size: 11, weight: .black, design: .monospaced))
                .foregroundStyle(.white)
                .frame(width: 20, height: 20)
                .background(Circle().fill(Color.white.opacity(0.18)))
            
            Text(text)
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.85))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
