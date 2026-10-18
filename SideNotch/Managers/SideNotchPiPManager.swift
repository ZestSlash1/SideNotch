import UIKit
import AVKit
import AVFoundation
import SwiftUI
import Combine

@MainActor
public final class SideNotchPiPManager: NSObject, ObservableObject, AVPictureInPictureControllerDelegate {
    public static let shared = SideNotchPiPManager()
    
    @Published public private(set) var isPiPActive: Bool = false
    private var pipController: AVPictureInPictureController?
    
    public override init() {
        super.init()
        configureAudioSession()
    }
    
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("SideNotchPiPManager: Failed to configure audio session: \(error)")
        }
    }
    
    public func setupPiP(with sourceView: UIView) {
        guard AVPictureInPictureController.isPictureInPictureSupported() else {
            print("SideNotchPiPManager: PiP is not supported on this device.")
            return
        }
        
        let pipCallVC = AVPictureInPictureVideoCallViewController()
        pipCallVC.preferredContentSize = CGSize(width: 80, height: 260)
        
        // Use a dedicated compact vertical strip for PiP window bounds
        let hostingController = UIHostingController(rootView: SideNotchPiPContentView())
        hostingController.view.backgroundColor = .black
        hostingController.view.frame = pipCallVC.view.bounds
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        pipCallVC.addChild(hostingController)
        pipCallVC.view.addSubview(hostingController.view)
        hostingController.didMove(toParent: pipCallVC)
        
        let contentSource = AVPictureInPictureController.ContentSource(
            activeVideoCallSourceView: sourceView,
            contentViewController: pipCallVC
        )
        
        pipController = AVPictureInPictureController(contentSource: contentSource)
        // Set to false so PiP does not automatically hijack the Home screen uninvited
        pipController?.canStartPictureInPictureAutomaticallyFromInline = false
        pipController?.delegate = self
    }
    
    public func togglePiP() {
        guard let pip = pipController else { return }
        if pip.isPictureInPictureActive {
            pip.stopPictureInPicture()
        } else {
            pip.startPictureInPicture()
        }
    }
    
    public func startPiP() {
        pipController?.startPictureInPicture()
    }
    
    public func stopPiP() {
        pipController?.stopPictureInPicture()
    }
    
    // MARK: - AVPictureInPictureControllerDelegate
    
    public func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        isPiPActive = true
    }
    
    public func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        isPiPActive = false
    }
}

/// Compact vertical widget tailored specifically for iOS Picture-in-Picture window constraints
private struct SideNotchPiPContentView: View {
    @ObservedObject private var stateManager = SideNotchStateManager.shared
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(stateManager.metrics) { metric in
                CircularGaugeItem(metric: metric)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}
