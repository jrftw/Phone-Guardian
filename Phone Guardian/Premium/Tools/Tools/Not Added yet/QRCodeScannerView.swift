// QRCodeScannerView.swift

import SwiftUI
import AVFoundation

struct QRCodeScannerView: View {
    @State private var scannedCode: String = ""
    @State private var isShowingScanner = false

    var body: some View {
        VStack {
            if scannedCode.isEmpty {
                Text("No QR code scanned yet.")
                    .padding()
            } else {
                Text("Scanned QR Code:")
                    .font(.headline)
                Text(scannedCode)
                    .padding()
            }

            Button(action: {
                isShowingScanner = true
            }) {
                Text("Scan QR Code")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .sheet(isPresented: $isShowingScanner) {
            QRCodeScanner(scannedCode: $scannedCode, isShowingScanner: $isShowingScanner)
        }
        .navigationTitle("QR Code Scanner")
    }
}

struct QRCodeScanner: UIViewControllerRepresentable {
    @Binding var scannedCode: String
    @Binding var isShowingScanner: Bool

    func makeUIViewController(context: Context) -> ScannerViewController {
        let scannerVC = ScannerViewController()
        scannerVC.delegate = context.coordinator
        return scannerVC
    }

    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {
        // No update needed
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var parent: QRCodeScanner

        init(parent: QRCodeScanner) {
            self.parent = parent
        }

        func metadataOutput(_ output: AVCaptureMetadataOutput,
                            didOutput metadataObjects: [AVMetadataObject],
                            from connection: AVCaptureConnection) {
            if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
               let code = metadataObject.stringValue {
                DispatchQueue.main.async {
                    self.parent.scannedCode = code
                    self.parent.isShowingScanner = false
                }
            }
        }
    }
}

class ScannerViewController: UIViewController {
    var delegate: QRCodeScanner.Coordinator?
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            // Handle error
            return
        }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            // Failed to add input
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(delegate, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            // Failed to add output
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        captureSession.startRunning()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
