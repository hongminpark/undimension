//

import SwiftUI
import SceneKit
import AVFoundation

struct ContentView: View {
    let usdzFile = "Balenciaga_Defender"
    @State private var captureSnapshot = false
    @State private var record = false
    @StateObject private var sceneHolder = SceneHolder()
    @State private var frameCaptureManager: FrameCaptureManager?
    @State private var isCapturing = false

    var body: some View {
        VStack {
            SceneKitView(fileName: usdzFile, captureSnapshot: $captureSnapshot, sceneHolder: sceneHolder)
            .frame(height: 300)
            .padding()
            .cornerRadius(12)
            Button("play") {
                sceneHolder.addRotationAnimation(x: 0, y: 0, z: CGFloat.pi * 2/4, duration: 2)
                sceneHolder.applyAnimations()
            }
            .padding()
            .background(.black)
            .foregroundColor(.white)
            Button("move") {
                sceneHolder.addRotationAnimation(x: 0, y: 0, z: CGFloat.pi * 2, duration: 10)
                sceneHolder.updateAnimation(5.0)
            }
            .padding()
            .background(.black)
            .foregroundColor(.white)
            Button("export") {
                sceneHolder.addRotationAnimation(x: 0, y: 0, z: CGFloat.pi * 2/4, duration: 2)
                sceneHolder.exportVideo()
            }
            .padding()
            .background(.black)
            .foregroundColor(.white)
        }
    }
}

#Preview {
    ContentView()
}
