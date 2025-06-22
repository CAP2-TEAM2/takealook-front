import SwiftUI
import AVFoundation

struct CameraView: View {
    var body: some View {
        CameraPreview()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct CameraPreview: NSViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> NSView {
        let view = NSView()

        context.coordinator.session.sessionPreset = .low

        guard
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
            let input = try? AVCaptureDeviceInput(device: device),
            context.coordinator.session.canAddInput(input)
        else {
            return view
        }

        context.coordinator.session.addInput(input)

        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(context.coordinator, queue: context.coordinator.queue)
        if context.coordinator.session.canAddOutput(videoOutput) {
            context.coordinator.session.addOutput(videoOutput)
        }

        context.coordinator.previewLayer = AVCaptureVideoPreviewLayer(session: context.coordinator.session)
        context.coordinator.previewLayer?.videoGravity = .resizeAspectFill
        context.coordinator.previewLayer?.frame = view.bounds
        context.coordinator.previewLayer?.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        context.coordinator.previewLayer?.setAffineTransform(CGAffineTransform(scaleX: -1, y: 1))

        view.layer = CALayer()
        view.wantsLayer = true
        if let previewLayer = context.coordinator.previewLayer {
            view.layer?.addSublayer(previewLayer)
        }

        context.coordinator.session.startRunning()

        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        // No dynamic updates
    }

    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        let session = AVCaptureSession()
        let queue = DispatchQueue(label: "camera.frame.queue")
        var previewLayer: AVCaptureVideoPreviewLayer?
        private var lastSentTime = Date()
        private let frameInterval: TimeInterval = 1.0 / 10.0  // 5 FPS
        let ciContext = CIContext()

        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            let now = Date()
            if now.timeIntervalSince(lastSentTime) < frameInterval {
                return
            }
            lastSentTime = now

            guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

            let imageBufferCopy = imageBuffer
            DispatchQueue.global(qos: .default).async {
                let ciImage = CIImage(cvImageBuffer: imageBufferCopy)
                guard let cgImage = self.ciContext.createCGImage(ciImage, from: ciImage.extent) else {
                    print("❌ CIImage to CGImage failed")
                    return
                }

                let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
                guard let tiffData = nsImage.tiffRepresentation,
                      let bitmap = NSBitmapImageRep(data: tiffData),
                      let jpegData = bitmap.representation(using: .jpeg, properties: [:]) else {
                    print("❌ JPEG conversion failed")
                    return
                }

//                print("📡 JPEG ready, sending to server...")
                let dataToSend = jpegData
                DispatchQueue.global(qos: .utility).async {
                    let result = SocketClient().sendImageData(dataToSend)
                    DispatchQueue.main.async {
                        ServerResponseStore.shared.value = (result ?? 999999) / 10
                        ServerResponseStore.shared.gesture = (result ?? 0) % 10
                    }
                }
            }
        }
        
        func captureSingleFrame(completion: @escaping (NSImage?) -> Void) {
            let session = AVCaptureSession()
            session.sessionPreset = .high

            guard let device = AVCaptureDevice.default(for: .video),
                  let input = try? AVCaptureDeviceInput(device: device),
                  session.canAddInput(input) else {
                completion(nil)
                return
            }

            session.addInput(input)

            let output = AVCaptureVideoDataOutput()
            let queue = DispatchQueue(label: "capture-single-frame")
            output.setSampleBufferDelegate(SingleFrameDelegate(completion: { image in
                DispatchQueue.main.async {
                    completion(image)
                }
                session.stopRunning()
            }), queue: queue)

            guard session.canAddOutput(output) else {
                completion(nil)
                return
            }

            session.addOutput(output)
            session.startRunning()
        }
    }
}

class SingleFrameDelegate: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    let completion: (NSImage?) -> Void
    private var captured = false

    init(completion: @escaping (NSImage?) -> Void) {
        self.completion = completion
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard !captured,
              let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }

        captured = true
        let ciImage = CIImage(cvImageBuffer: imageBuffer)
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            print("❌ CIImage to CGImage failed (single frame)")
            completion(nil)
            return
        }

        let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
        completion(nsImage)
    }
}

class ServerResponseStore: ObservableObject {
    static let shared = ServerResponseStore()
    @Published var value: Int?
    @Published var gesture: Int?
}

enum CameraFrame {
    static func capture(completion: @escaping (NSImage?) -> Void) {
        let session = AVCaptureSession()
        session.sessionPreset = .high

        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            completion(nil)
            return
        }

        session.addInput(input)

        let output = AVCaptureVideoDataOutput()
        let queue = DispatchQueue(label: "single.frame.queue")
        output.setSampleBufferDelegate(SingleFrameDelegate(completion: { image in
            DispatchQueue.main.async {
                completion(image)
            }
            session.stopRunning()
        }), queue: queue)

        guard session.canAddOutput(output) else {
            completion(nil)
            return
        }

        session.addOutput(output)
        session.startRunning()
    }
}
