//

import Foundation
import SceneKit
import SwiftUI

class SceneHolder: ObservableObject {
    var animation: Animation?
    var animator: Animator? // Store the animator
    @Published var scnView: SCNView?
    @State private var frameCaptureManager: FrameCaptureManager?

    func addRotationAnimation(x: CGFloat, y: CGFloat, z: CGFloat, duration: TimeInterval) {
        let keyframes = [
            Keyframe(time: 0, rotation: SCNVector4(0, 0, 0, 0)),
            Keyframe(time: duration, rotation: SCNVector4(x, y, z, CGFloat.pi * 2))
        ]

        animation = Animation(keyframes: keyframes, duration: duration)
    }
    
    func applyAnimations() {
        guard let scnView = scnView, let rootNode = scnView.scene?.rootNode else { return }
        animator = Animator(node: rootNode)
        animator?.animation = self.animation
        animator?.applyAnimation()
    }
    
    func updateAnimation(_ to: TimeInterval) {
        guard let scnView = scnView, let rootNode = scnView.scene?.rootNode else { return }
        animator = Animator(node: rootNode)
        animator?.animation = self.animation
        animator?.updateAnimation(to: to)
    }
    
    func pauseAnimations() {
        animator?.pauseAnimation()
    }

    func resumeAnimations() {
        animator?.resumeAnimation()
    }
    
    func exportVideo() {
        guard let scnView = scnView, let scene = scnView.scene else { return }
        animator = Animator(node: scene.rootNode)
        animator?.animation = self.animation
        let frameCaptureManager = FrameCaptureManager(scene: scene, view: scnView, animator: animator!)
        frameCaptureManager.startCapture()
    }
    
}
