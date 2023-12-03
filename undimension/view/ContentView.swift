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

    @State private var currentTime: CGFloat = 0
    @State private var durationText: String = "12"
    @State private var duration: CGFloat = 12
    @State private var timer: Timer?
    @State private var isPlaying = false

    var body: some View {
        VStack {
            SceneKitView(fileName: usdzFile, captureSnapshot: $captureSnapshot, sceneHolder: sceneHolder)
            .frame(height: 300)
            .padding()
            .cornerRadius(12)
            Button("export") {
                sceneHolder.addRotationAnimation(x: 0, y: 0, z: CGFloat.pi * 2/4, duration: 2)
                sceneHolder.exportVideo()
            }
            .padding()
            .background(.black)
            .foregroundColor(.white)
            VStack {
                Button("Play") {
                    // Reset the slider to 0
                    isPlaying = true
                    currentTime = 0
                    sceneHolder.animation = nil

                    // Invalidate any existing timer
                    timer?.invalidate()

                    // Create a new timer that updates the slider value
                    timer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { _ in
                        // Update slider value
                        if self.currentTime < self.duration {
                            self.currentTime += CGFloat(1.0/60.0 * self.duration / self.duration)
                            sceneHolder.updateAnimation(self.currentTime)
                        } else {
                            self.timer?.invalidate() // Invalidate timer when the end is reached
                        }
                    }

                    sceneHolder.addRotationAnimation(x: 0, y: 0, z: CGFloat.pi * 2, duration: CGFloat(self.duration))
                    sceneHolder.applyAnimations()
                }
                .padding()
                .background(.black)
                .foregroundColor(.white)
                Button(isPlaying ? "Pause" : "Resume") {
                    if isPlaying {
                        timer?.invalidate()
                        timer = nil
                        sceneHolder.pauseAnimations()
                    } else {
                        // Resume the animation
                        sceneHolder.resumeAnimations()
                        // Re-create and schedule the timer
                        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { _ in
                            DispatchQueue.main.async {
                                if self.currentTime < self.duration {
                                    self.currentTime += CGFloat(1.0 / 60.0 * self.duration / self.duration)
                                    sceneHolder.updateAnimation(self.currentTime)
                                } else {
                                    self.currentTime = self.duration
                                    self.timer?.invalidate()
                                    self.timer = nil
                                }
                            }
                        }
                        
                        // Add the timer to the current run loop
                        RunLoop.current.add(self.timer!, forMode: .common)
                    }
                    isPlaying.toggle()
                }
                .padding()
                .background(isPlaying ? .black : .gray)
                .foregroundColor(.white)
                HStack {
                    Text("\(currentTime, specifier: "%.f")s")
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
                                duration = CGFloat(value)
                            }
                        }
                        .onChange(of: durationText) { newValue in
                            if let value = NumberFormatter().number(from: newValue)?.doubleValue {
                                duration = CGFloat(value)
                            }
                        }
                    Text("s")
                }
                .padding()
                CustomSlider(value: $currentTime, range: 0...duration, step: 0.01)
                    .onChange(of: currentTime) { newValue in
                        if sceneHolder.animation == nil {
                            sceneHolder.addRotationAnimation(x: 0, y: 0, z: CGFloat.pi * 2, duration: duration)
                        }
                        sceneHolder.updateAnimation(newValue)
                    }
                    .padding()
            }

        }
    }
}

struct CustomSlider: View {
    @Binding var value: CGFloat
    let range: ClosedRange<CGFloat>
    let step: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // The timeline track
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 5)
                
                // The timeline progress
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: geometry.size.width * (value - range.lowerBound) / (range.upperBound - range.lowerBound), height: 5)
                
                // The draggable indicator
                Circle()
                    .fill(Color.white)
                    .frame(width: 25, height: 25)
                    .shadow(radius: 2)
                    .offset(x: geometry.size.width * (value - range.lowerBound) / (range.upperBound - range.lowerBound) - 12.5)
                    .gesture(DragGesture(minimumDistance: 0).onChanged({ gesture in
                        let sliderWidth = geometry.size.width
                        let newValue = (gesture.location.x / sliderWidth) * (range.upperBound - range.lowerBound) + range.lowerBound
                        value = min(max(newValue, range.lowerBound), range.upperBound)
                    }))
            }
        }
        .frame(height: 25)
    }
}
#Preview {
    ContentView()
}
