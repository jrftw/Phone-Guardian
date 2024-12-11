// DocumentConversionView.swift

import SwiftUI
import PhotosUI
import MobileCoreServices
import UniformTypeIdentifiers
import os.log

struct DocumentConversionView: View {
    @State private var selectedFileURL: URL?
    @State private var convertedFileURL: URL?
    @State private var isFilePickerPresented = false
    @State private var isPhotoPickerPresented = false
    @State private var conversionError: String?
    @State private var isProcessing = false
    @State private var showShareSheet = false

    var body: some View {
        VStack(spacing: 20) {
            Text("File Conversion")
                .font(.largeTitle)
                .bold()
                .padding(.top)

            if let selectedFileURL = selectedFileURL {
                Text("Selected File: \(selectedFileURL.lastPathComponent)")
                    .foregroundColor(.blue)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                Text("No file selected.")
                    .foregroundColor(.gray)
                    .padding()
            }

            if let convertedFileURL = convertedFileURL {
                VStack {
                    Text("Converted File:")
                    Button(action: { showShareSheet = true }) {
                        Text(convertedFileURL.lastPathComponent)
                            .foregroundColor(.blue)
                            .underline()
                    }
                    .sheet(isPresented: $showShareSheet) {
                        ActivityView(activityItems: [convertedFileURL])
                    }
                }
            }

            if let conversionError = conversionError {
                Text("Error: \(conversionError)")
                    .foregroundColor(.red)
            }

            Spacer()

            VStack(spacing: 16) {
                Button(action: { isFilePickerPresented.toggle() }) {
                    HStack {
                        Image(systemName: "doc.badge.plus")
                        Text("Select File")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }

                Button(action: { isPhotoPickerPresented.toggle() }) {
                    HStack {
                        Image(systemName: "photo.on.rectangle")
                        Text("Select Photos/Videos")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }

                if selectedFileURL != nil && !isProcessing {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ConversionButton(iconName: "doc.text", title: "PDF", action: convertToPDF)
                            ConversionButton(iconName: "photo", title: "Image", action: convertToImage)
                            ConversionButton(iconName: "waveform", title: "Audio", action: convertToAudio)
                            ConversionButton(iconName: "video", title: "Video", action: convertToVideo)
                            ConversionButton(iconName: "archivebox", title: "ZIP", action: convertToZip)
                        }
                    }
                    .padding(.top)
                }
            }

            Spacer()

            if isProcessing {
                ProgressView("Processing...")
                    .padding()
            }
        }
        .padding()
        .fileImporter(isPresented: $isFilePickerPresented, allowedContentTypes: [.item]) { result in
            handleFileSelection(result: result)
        }
        .fullScreenCover(isPresented: $isPhotoPickerPresented) {
            PhotoPickerView(onPick: handlePhotoPick)
        }
        .navigationTitle("File Conversion")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func handleFileSelection(result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            selectedFileURL = url
            conversionError = nil
            convertedFileURL = nil
        case .failure(let error):
            conversionError = "Failed to select file: \(error.localizedDescription)"
        }
    }

    private func handlePhotoPick(url: URL) {
        selectedFileURL = url
        conversionError = nil
        convertedFileURL = nil
    }

    private func convertToPDF() {
        guard let inputURL = selectedFileURL else { return }
        isProcessing = true
        DocumentConversionManager.convertToPDF(inputURL: inputURL) { result in
            handleConversionResult(result)
        }
    }

    private func convertToImage() {
        guard let inputURL = selectedFileURL else { return }
        isProcessing = true
        DocumentConversionManager.convertToImage(inputURL: inputURL) { result in
            handleConversionResult(result)
        }
    }

    private func convertToAudio() {
        guard let inputURL = selectedFileURL else { return }
        isProcessing = true
        DocumentConversionManager.convertToAudio(inputURL: inputURL) { result in
            handleConversionResult(result)
        }
    }

    private func convertToVideo() {
        guard let inputURL = selectedFileURL else { return }
        isProcessing = true
        DocumentConversionManager.convertToVideo(inputURL: inputURL) { result in
            handleConversionResult(result)
        }
    }

    private func convertToZip() {
        guard let inputURL = selectedFileURL else { return }
        isProcessing = true
        DocumentConversionManager.convertToZip(inputURL: inputURL) { result in
            handleConversionResult(result)
        }
    }

    private func handleConversionResult(_ result: Result<URL, Error>) {
        DispatchQueue.main.async {
            isProcessing = false
            switch result {
            case .success(let url):
                convertedFileURL = url
                conversionError = nil
            case .failure(let error):
                conversionError = error.localizedDescription
            }
        }
    }
}

struct ConversionButton: View {
    let iconName: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: iconName)
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Color.blue)
                    .cornerRadius(30)
                Text(title)
                    .font(.footnote)
                    .foregroundColor(.blue)
            }
        }
    }
}

struct PhotoPickerView: UIViewControllerRepresentable {
    let onPick: (URL) -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .any(of: [.images, .videos])
        configuration.selectionLimit = 1
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onPick: onPick)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let onPick: (URL) -> Void

        init(onPick: @escaping (URL) -> Void) {
            self.onPick = onPick
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let provider = results.first?.itemProvider else { return }
            let tempDirectory = FileManager.default.temporaryDirectory

            if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                provider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { url, error in
                    if let url = url {
                        let tempURL = tempDirectory.appendingPathComponent(url.lastPathComponent)
                        try? FileManager.default.copyItem(at: url, to: tempURL)
                        DispatchQueue.main.async {
                            self.onPick(tempURL)
                        }
                    }
                }
            } else if provider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                provider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, error in
                    if let url = url {
                        let tempURL = tempDirectory.appendingPathComponent(url.lastPathComponent)
                        try? FileManager.default.copyItem(at: url, to: tempURL)
                        DispatchQueue.main.async {
                            self.onPick(tempURL)
                        }
                    }
                }
            }
        }
    }
}

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
