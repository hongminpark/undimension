//

import Foundation
import SceneKit
import SwiftUI

class SceneHolder: ObservableObject {
    var animation: Animation?
    var scnRenderer: SCNRenderer?
    @Published var scnView: SCNView?
    private var frameCaptureManager: FrameCaptureManager?
    @Published var isPlaying = false // Flag to indicate if the animation is playing
    @Published var currentTime: CGFloat = 0
    @Published var duration: CGFloat = 12
    var timer: Timer?
    
    private let FPS = 60.0
    
    // FIXME - Animation.duration vs self.duration 정리
    func initialize(_ scnView: SCNView) {
        let scnRenderer = SCNRenderer(device: nil, options: nil)
        scnRenderer.scene = scnView.scene
        scnRenderer.autoenablesDefaultLighting = true
        scnRenderer.pointOfView = scnView.pointOfView
        self.scnRenderer = scnRenderer
        self.scnView = scnView
        self.frameCaptureManager = FrameCaptureManager(sceneHolder: self)
        
        // set default animation
        addRotationAnimation(x: 0, y: 0, z: CGFloat.pi * 2, duration: duration)
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
    
    func startAnimation() {
        currentTime = 0
        applyAnimations()
        createTimer()
        isPlaying = true // Set flag to true when animation starts

    }

    func stopAnimation() {
        timer?.invalidate()
        timer = nil
        isPlaying = false // Set flag to false when animation stops
    }
    
    func togglePauseResume() {
        if isPlaying {
            pauseAnimations()
            stopAnimation()
        } else {
            resumeAnimations()
            createTimer()
            isPlaying = true
        }
    }

    private func createTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / FPS, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.currentTime < self.duration {
                self.currentTime += CGFloat(1.0 / FPS)
                self.updateAnimation(self.currentTime)
            } else {
                self.timer?.invalidate()
                self.timer = nil
            }
        }

        if let timer = self.timer {
            RunLoop.current.add(timer, forMode: .common)
        }
    }

}
