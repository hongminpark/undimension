//

import Foundation
import SceneKit

class Animator {
    static func applyAnimation(to node: SCNNode, using animation: Animation) {
        let actions = animation.keyframes.map { keyframe -> SCNAction in
            SCNAction.rotateTo(x: CGFloat(keyframe.rotation.x),
                               y: CGFloat(keyframe.rotation.y),
                               z: CGFloat(keyframe.rotation.z),
                               duration: keyframe.time)
        }
        
        let sequence = SCNAction.sequence(actions)
        node.runAction(sequence, forKey: "rotationAnimation")
    }
    
    static func updateAnimation(of node: SCNNode, using animation: Animation, to time: TimeInterval) {
        if let firstKeyframe = animation.keyframes.first,
           let lastKeyframe = animation.keyframes.last {
            
            // linear interpolation
            let progress = min(max(time / animation.duration, 0), 1)
            let startRotation = firstKeyframe.rotation
            let endRotation = lastKeyframe.rotation
            let interpolatedRotation = interpolate(start: startRotation, end: endRotation, progress: progress)
            
            node.eulerAngles = SCNVector3(interpolatedRotation.x, interpolatedRotation.y, interpolatedRotation.z)
        }
    }
    
    static func pauseAnimation(for node: SCNNode) {
        node.isPaused = true
    }
    
    static func resumeAnimation(for node: SCNNode) {
        node.isPaused = false
    }

    private static func interpolate(start: SCNVector4, end: SCNVector4, progress: CGFloat) -> SCNVector4 {
        let floatProgress = Float(progress)  // Convert progress to Float

        let deltaX = (end.x - start.x) * floatProgress
        let deltaY = (end.y - start.y) * floatProgress
        let deltaZ = (end.z - start.z) * floatProgress
        let deltaW = (end.w - start.w) * floatProgress

        let interpolatedX = start.x + deltaX
        let interpolatedY = start.y + deltaY
        let interpolatedZ = start.z + deltaZ
        let interpolatedW = start.w + deltaW

        return SCNVector4(interpolatedX, interpolatedY, interpolatedZ, interpolatedW)
    }

}
