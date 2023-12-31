//

import Foundation
import AVFoundation
import SceneKit

class FrameCaptureManager {
    private var displayLink: CADisplayLink?
    private var isCapturing = false
    private var currentFrame = 0
    private var framesDirectory: URL?
    private weak var sceneHolder: SceneHolder?

    init(sceneHolder: SceneHolder) {
        self.sceneHolder = sceneHolder
    }

    func startCapture() {
        isCapturing = true
        displayLink = CADisplayLink(target: self, selector: #selector(renderAndCapture))
        displayLink?.add(to: .current, forMode: .common)
        createFramesDirectory()
    }
    
    func stopCapture() {
        displayLink?.invalidate()
        isCapturing = false
    }

    @objc private func renderAndCapture() {
        if isCapturing {
            let fps = 60.0
            guard let scnHolder = self.sceneHolder else { return }
            let frameCount = Int(fps * scnHolder.duration)

            for frame in 0...frameCount {
                let currentTime = (scnHolder.duration / Double(frameCount)) * Double(frame)
                guard let rootNode = scnHolder.scnView?.scene?.rootNode, let scnRenderer = scnHolder.scnRenderer else { return }
                Animator.updateAnimation(of: rootNode, using: scnHolder.animation!, to: currentTime)
                let snapshot = scnRenderer.snapshot(atTime: currentTime, with: CGSize(width: 1080, height: 1080), antialiasingMode: .none)
                if let data = snapshot.pngData() {
                    saveFrame(data: data)
                }
            }

            generateVideoFromImages()
            isCapturing = false
            currentFrame = 0
        }
    }
    
    private func createFramesDirectory() {
        let tempDir = FileManager.default.temporaryDirectory
        let directoryName = UUID().uuidString
        let directoryURL = tempDir.appendingPathComponent(directoryName)
        do {
            try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
            framesDirectory = directoryURL
        } catch {
            print("Error creating frames directory: \(error)")
        }
    }

    private func saveFrame(data: Data) {
        guard let directory = framesDirectory else { return }
        
        let fileName = String(format: "frame_%04d.png", currentFrame)
        let fileURL = directory.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            currentFrame += 1
        } catch {
            print("Error saving frame: \(error)")
        }
    }
    
    private func loadImagesFromDirectory(at path: URL) -> [UIImage] {
        do {
            let fileManager = FileManager.default
            let contents = try fileManager.contentsOfDirectory(at: path, includingPropertiesForKeys: nil, options: [])
            let imageFiles = contents.filter { $0.pathExtension == "png" }.sorted(by: { $0.lastPathComponent < $1.lastPathComponent })
            imageFiles.forEach { fileURL in
                print("Filename: \(fileURL.lastPathComponent)")
            }
            let images = imageFiles.compactMap { UIImage(contentsOfFile: $0.path) }
            return images
        } catch {
            print("Error reading contents of directory: \(error)")
            return []
        }
    }

    private func generateVideoFromImages() {
        let images: [UIImage] = loadImagesFromDirectory(at: framesDirectory!)

        VideoGenerator.fileName = "outputVideo"
        VideoGenerator.videoDurationInSeconds = 1

        VideoGenerator.current.generate(withImages: images, andAudios: [], andType: .multiple, { (progress) in
          print(progress)
        }, outcome: { (url) in
          print(url)
        })
    }

}
