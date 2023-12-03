//

import SwiftUI
import SceneKit
import AVFoundation

struct ContentView: View {
    let usdzFile = "Balenciaga_Defender"
    @State private var captureSnapshot = false
    @StateObject private var sceneHolder = SceneHolder()
    @State private var durationText: String = "12"

    var body: some View {
        VStack {
            SceneKitView(fileName: usdzFile, captureSnapshot: $captureSnapshot, sceneHolder: sceneHolder)
            .frame(height: 300)
            .padding()
            .cornerRadius(12)
            VStack {
                Button("export") {
                    sceneHolder.exportVideo()
                }
                .padding()
                .background(.black)
                .foregroundColor(.white)
                Button("Play") {
                     sceneHolder.startAnimation()
                 }
                 .padding()
                 .background(.black)
                 .foregroundColor(.white)

                 Button(sceneHolder.isPlaying ? "Pause" : "Resume") {
                     sceneHolder.togglePauseResume()
                 }
                 .padding()
                 .background(sceneHolder.isPlaying ? .black : .gray)
                 .foregroundColor(.white)

                HStack {
                    Text("\(sceneHolder.currentTime, specifier: "%.f")s")
                    Spacer()
                    TextField("Enter text here", text: $durationText)
                        .padding(.vertical, 10)
                        .background(GeometryReader { geometryProxy in
                            Text(durationText)
                                .frame(width: geometryProxy.size.width)
                                .opacity(0) // Make the text invisible
                        })
                        .border(Color.gray, width: 1)
                        .onSubmit {
                            if let value = NumberFormatter().number(from: durationText)?.doubleValue {
                                sceneHolder.duration = CGFloat(value)
                            }
                        }
                        .onChange(of: durationText) { newValue in
                            if let value = NumberFormatter().number(from: newValue)?.doubleValue {
                                sceneHolder.duration = CGFloat(value)
                            }
                        }
                    Text("s")
                }
                .padding()
                CustomSlider(value: $sceneHolder.currentTime, range: 0...sceneHolder.duration, step: 0.01)
                    .padding()
                    .onChange(of: sceneHolder.currentTime) { newValue in
                        sceneHolder.updateAnimation(newValue)
                    }
                    .padding()
            }

        }
    }
}

#Preview {
    ContentView()
}
