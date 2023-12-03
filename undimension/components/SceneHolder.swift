//

import Foundation
import SceneKit
import SwiftUI

class SceneHolder: ObservableObject {
    var animation: Animation?
    var scnRenderer: SCNRenderer?
    @Published var scnView: SCNView?
    private var frameCaptureManager: FrameCaptureManager?

    func initialize(_ scnView: SCNView) {
        let scnRenderer = SCNRenderer(device: nil, options: nil)
        scnRenderer.scene = scnView.scene
        scnRenderer.autoenablesDefaultLighting = true
        scnRenderer.pointOfView = scnView.pointOfView
        self.scnRenderer = scnRenderer
        self.scnView = scnView
        self.frameCaptureManager = FrameCaptureManager(sceneHolder: self)
    }

    func addRotationAnimation(x: CGFloat, y: CGFloat, z: CGFloat, duration: TimeInterval) {
        let keyframes = [
            Keyframe(time: 0, rotation: SCNVector4(0, 0, 0, 0)),
            Keyframe(time: duration, rotation: SCNVector4(x, y, z, CGFloat.pi * 2))
        ]

        animation = Animation(keyframes: keyframes, duration: duration)
    }
    
    func applyAnimations() {
        guard let scnView = scnView, let rootNode = scnView.scene?.rootNode, let animation = self.animation else { return }
        Animator.applyAnimation(to: rootNode, using: animation)
    }
    
    func updateAnimation(_ to: TimeInterval) {
        guard let scnView = scnView, let rootNode = scnView.scene?.rootNode, let animation = self.animation else { return }
        Animator.updateAnimation(of: rootNode, using: animation, to: to)
    }
    
    func pauseAnimations() {
        guard let scnView = scnView, let rootNode = scnView.scene?.rootNode else { return }
        Animator.pauseAnimation(for: rootNode)
    }

    func resumeAnimations() {
        guard let scnView = scnView, let rootNode = scnView.scene?.rootNode else { return }
        Animator.resumeAnimation(for: rootNode)
    }
    
    func exportVideo() {
        frameCaptureManager?.startCapture()
    }
    
}
