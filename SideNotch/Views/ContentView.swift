import SwiftUI
import UIKit

public struct ContentView: View {
    public init() {}
    
    public var body: some View {
        ZStack {
            WallpaperMockupBackground()
            SideLiquidNotchView()
            
            // Background PiP anchor source view
            PiPAnchorView { sourceView in
                SideNotchPiPManager.shared.setupPiP(with: sourceView)
            }
            .frame(width: 1, height: 1)
            .opacity(0.01)
            .allowsHitTesting(false)
        }
        .ignoresSafeArea()
    }
}

private struct PiPAnchorView: UIViewRepresentable {
    let onSetup: (UIView) -> Void
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        view.backgroundColor = .clear
        DispatchQueue.main.async {
            onSetup(view)
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
