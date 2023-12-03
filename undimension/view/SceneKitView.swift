//

import SwiftUI
import SceneKit

struct SceneKitView: UIViewRepresentable {
    let fileName: String
    @Binding var captureSnapshot: Bool
    var sceneHolder: SceneHolder

    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.autoenablesDefaultLighting = true
        sceneView.allowsCameraControl = true
        sceneView.backgroundColor = .clear

        if let url = Bundle.main.url(forResource: fileName, withExtension: "usdz"),
           let scene = try? SCNScene(url: url, options: nil) {
            sceneView.scene = scene
            sceneHolder.scnView = sceneView
        }
        sceneHolder.scnView = sceneView
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        if captureSnapshot {
            let image = uiView.snapshot()
            if let pngData = image.pngData(), let pngImage = UIImage(data: pngData) {
                UIImageWriteToSavedPhotosAlbum(pngImage, nil, nil, nil)
            }
            captureSnapshot = false
        }
    }
    
    static func rotate(for scnScene: SCNScene, x: CGFloat, y: CGFloat, z: CGFloat, duration: TimeInterval) {
        let rootNode = scnScene.rootNode
        rootNode.eulerAngles = SCNVector3(0, 0, 0)
        rootNode.position = SCNVector3(0, 0, 0)
        rootNode.scale = SCNVector3(1, 1, 1)
        let rotation = SCNAction.rotateBy(x: x, y: y, z: z, duration: duration)
        let repeatRotation = SCNAction.repeatForever(rotation)
        rootNode.runAction(repeatRotation, forKey: "rotationKey")
    }
}
