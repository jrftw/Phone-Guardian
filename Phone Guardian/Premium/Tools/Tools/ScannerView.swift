import SwiftUI
import VisionKit
import AVFoundation
import Photos
import os.log

// MARK: - ScannerView

struct ScannerView: View {
    @State private var isShowingScanner = false
    @State private var scannedDocuments: [ScannedDocument] = []
    @State private var cameraPermissionDenied = false
    @State private var showSaveConfirmation = false
    @State private var saveConfirmationMessage = ""

    var body: some View {
        VStack {
            Text("Scanner")
                .font(.title2)
                .bold()
                .padding()

            if cameraPermissionDenied {
                Text("Camera access is required to scan documents. Please enable camera access in Settings.")
                    .font(.body)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            } else if scannedDocuments.isEmpty {
                Text("No scanned documents yet. Start scanning to add files.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                List {
                    ForEach(scannedDocuments) { document in
                        NavigationLink(destination: DocumentDetailView(document: document, onSaveToPhotos: saveToPhotos, onSaveToFile: saveToFile)) {
                            Text(document.fileName)
                        }
                    }
                }
            }

            Spacer()

            Button(action: {
                requestCameraAccess {
                    isShowingScanner = $0
                }
            }) {
                Text("Scan Document")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(cameraPermissionDenied ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            .disabled(cameraPermissionDenied)
            .fullScreenCover(isPresented: $isShowingScanner) {
                DocumentScannerView(scannedDocuments: $scannedDocuments, onSaveHistory: saveScannedDocumentsToUserDefaults)
            }
            .alert(isPresented: $showSaveConfirmation) {
                Alert(title: Text("Success"), message: Text(saveConfirmationMessage), dismissButton: .default(Text("OK")))
            }
        }
        .padding()
        .navigationTitle("Document Scanner")
        .onAppear {
            checkCameraPermission()
            loadScannedDocumentsFromUserDefaults()
        }
    }

    // MARK: - Camera Permission Handling

    private func checkCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .denied || status == .restricted {
            cameraPermissionDenied = true
            os_log("Camera access denied or restricted.")
        }
    }

    private func requestCameraAccess(completion: @escaping (Bool) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    self.cameraPermissionDenied = !granted
                    os_log("Camera access %@", granted ? "granted" : "denied")
                    completion(granted)
                }
            }
        case .authorized:
            completion(true)
        default:
            completion(false)
        }
    }

    // MARK: - Save to Photos

    private func saveToPhotos(document: ScannedDocument) {
        if let image = UIImage(data: document.imageData) {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }, completionHandler: { success, error in
                DispatchQueue.main.async {
                    if success {
                        self.saveConfirmationMessage = "Image saved to Photos."
                        os_log("Image saved to Photos successfully.")
                    } else {
                        self.saveConfirmationMessage = "Failed to save image to Photos."
                        os_log("Error saving image to Photos: %@", error?.localizedDescription ?? "Unknown error")
                    }
                    self.showSaveConfirmation = true
                }
            })
            os_log("Saving document to Photos: %@", document.fileName)
        }
    }

    // MARK: - Save to Files

    private func saveToFile(document: ScannedDocument) {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent(document.fileName)

        do {
            try document.imageData.write(to: fileURL)
            os_log("Document saved to Files: %@", fileURL.path)
            saveConfirmationMessage = "Document saved to Files."
            showSaveConfirmation = true
        } catch {
            os_log("Error saving file: %@", error.localizedDescription)
            saveConfirmationMessage = "Failed to save document to Files."
            showSaveConfirmation = true
        }
    }

    // MARK: - Persistent History

    private func saveScannedDocumentsToUserDefaults() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(Array(scannedDocuments.prefix(10))) {
            UserDefaults.standard.set(encoded, forKey: "ScannedDocuments")
            os_log("Scanned documents saved to UserDefaults.")
        } else {
            os_log("Failed to encode scanned documents.", type: .error)
        }
    }

    private func loadScannedDocumentsFromUserDefaults() {
        if let savedData = UserDefaults.standard.data(forKey: "ScannedDocuments") {
            let decoder = JSONDecoder()
            if let loadedDocuments = try? decoder.decode([ScannedDocument].self, from: savedData) {
                scannedDocuments = loadedDocuments
                os_log("Scanned documents loaded from UserDefaults.")
            } else {
                os_log("Failed to decode scanned documents.", type: .error)
            }
        }
    }
}

// MARK: - DocumentScannerView

struct DocumentScannerView: UIViewControllerRepresentable {
    @Binding var scannedDocuments: [ScannedDocument]
    var onSaveHistory: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scanner = VNDocumentCameraViewController()
        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}

    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        var parent: DocumentScannerView

        init(_ parent: DocumentScannerView) {
            self.parent = parent
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            os_log("Scanning completed with %d pages.", scan.pageCount)
            for pageIndex in 0..<scan.pageCount {
                if let imageData = scan.imageOfPage(at: pageIndex).jpegData(compressionQuality: 0.8) {
                    let fileName = "Scan-\(UUID().uuidString).jpg"
                    let document = ScannedDocument(fileName: fileName, imageData: imageData)
                    parent.scannedDocuments.insert(document, at: 0)
                    os_log("Scanned document added: %@", fileName)
                }
            }
            controller.dismiss(animated: true)
            parent.onSaveHistory()
        }

        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            os_log("Document scanning cancelled.")
            controller.dismiss(animated: true)
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            os_log("Document scanning failed: %@", error.localizedDescription)
            controller.dismiss(animated: true)
        }
    }
}

// MARK: - DocumentDetailView

struct DocumentDetailView: View {
    let document: ScannedDocument
    let onSaveToPhotos: (ScannedDocument) -> Void
    let onSaveToFile: (ScannedDocument) -> Void

    var body: some View {
        VStack {
            if let image = UIImage(data: document.imageData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding()
            } else {
                Text("Unable to display image")
                    .foregroundColor(.red)
            }

            Text("File Name: \(document.fileName)")
                .font(.footnote)
                .padding()

            Spacer()

            Button(action: {
                onSaveToPhotos(document)
            }) {
                Text("Save to Photos")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            Button(action: {
                onSaveToFile(document)
            }) {
                Text("Save to Files")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .navigationTitle("Document Details")
    }
}

// MARK: - ScannedDocument Model

struct ScannedDocument: Identifiable, Codable {
    let id: UUID
    let fileName: String
    let imageData: Data

    init(id: UUID = UUID(), fileName: String, imageData: Data) {
        self.id = id
        self.fileName = fileName
        self.imageData = imageData
    }
}
