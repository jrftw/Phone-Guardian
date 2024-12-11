// ReportsView.swift

import SwiftUI
import PDFKit
import Network
import CoreMotion
import AVFoundation
import os

struct ReportsView: View {
    @State private var showShareSheet = false
    @State private var pdfURL: URL?
    @State private var showPDFPreview = false
    @State private var savedReports: [Report] = loadSavedReports()

    var body: some View {
        VStack(spacing: 20) {
            Button("Export Report") {
                generatePDFReport()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)

            if !savedReports.isEmpty {
                List(savedReports) { report in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(report.fileName)
                                .font(.headline)
                            Text(report.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Button("Preview") {
                            pdfURL = report.fileURL
                            showPDFPreview = true
                        }
                        .foregroundColor(.blue)
                    }
                }
                .listStyle(PlainListStyle())
                .frame(maxHeight: 300)
            } else {
                Text("No saved reports yet.")
                    .foregroundColor(.gray)
            }

            Spacer()

            if let pdfURL = pdfURL {
                Button("Preview Latest Report") {
                    showPDFPreview = true
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                .sheet(isPresented: $showPDFPreview) {
                    PDFPreviewView(pdfURL: pdfURL)
                }

                Button("Share Report") {
                    showShareSheet = true
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(10)
                .sheet(isPresented: $showShareSheet) {
                    ShareSheet(activityItems: [pdfURL])
                }
            }
        }
        .padding()
        .navigationTitle("Reports")
    }

    func generatePDFReport() {
        let pdfContent = createPDFContent()
        let pageBounds = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: pageBounds)

        let data = renderer.pdfData { context in
            context.beginPage()
            pdfContent.draw(in: CGRect(x: 20, y: 20, width: pageBounds.width - 40, height: pageBounds.height - 40))
        }

        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileName = "Report-\(UUID().uuidString).pdf"
            let pdfFileURL = documentDirectory.appendingPathComponent(fileName)
            do {
                try data.write(to: pdfFileURL)
                self.pdfURL = pdfFileURL

                let newReport = Report(fileName: fileName, fileURL: pdfFileURL, date: Date())
                savedReports.insert(newReport, at: 0)

                if savedReports.count > 10 {
                    savedReports.removeLast()
                }

                saveReportsToUserDefaults()
            } catch {
                print("Error saving PDF: \(error)")
            }
        }
    }

    func createPDFContent() -> NSAttributedString {
        let deviceInfo = fetchDeviceInfo()
        let batteryInfo = fetchBatteryInfo()
        let storageInfo = fetchStorageInfo()
        let networkInfo = fetchNetworkInfo()
        let cpuInfo = fetchCPUUsage()
        let ramInfo = fetchRAMInfo()
        let sensorInfo = fetchSensorInfo()
        let cameraInfo = fetchCameraInfo()

        let content = """
        Phone Guardian Report
        =====================

        Date: \(Date().formatted(date: .numeric, time: .shortened))

        Device Info:
        \(deviceInfo)

        Battery Info:
        \(batteryInfo)

        Storage Info:
        \(storageInfo)

        Network Info:
        \(networkInfo)

        CPU Info:
        \(cpuInfo)

        RAM Info:
        \(ramInfo)

        Sensor Info:
        \(sensorInfo)

        Camera Info:
        \(cameraInfo)

        Thank you for using Phone Guardian!
        """

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14),
            .paragraphStyle: {
                let style = NSMutableParagraphStyle()
                style.alignment = .left
                style.lineSpacing = 6
                return style
            }()
        ]

        return NSAttributedString(string: content, attributes: attributes)
    }

    func fetchDeviceInfo() -> String {
        return """
        Device Name: \(UIDevice.current.name)
        System Version: \(UIDevice.current.systemVersion)
        Model: \(UIDevice.current.model)
        """
    }

    func fetchBatteryInfo() -> String {
        UIDevice.current.isBatteryMonitoringEnabled = true
        return """
        Battery Level: \(Int(UIDevice.current.batteryLevel * 100))%
        Battery State: \(UIDevice.current.batteryState)
        """
    }

    func fetchStorageInfo() -> String {
        let fileManager = FileManager.default
        if let homeDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            do {
                let attributes = try fileManager.attributesOfFileSystem(forPath: homeDirectory.path)
                let totalSpace = attributes[.systemSize] as? Int64 ?? 0
                let freeSpace = attributes[.systemFreeSize] as? Int64 ?? 0
                let usedSpace = totalSpace - freeSpace
                return """
                Total: \(ByteCountFormatter.string(fromByteCount: totalSpace, countStyle: .file))
                Used: \(ByteCountFormatter.string(fromByteCount: usedSpace, countStyle: .file))
                Free: \(ByteCountFormatter.string(fromByteCount: freeSpace, countStyle: .file))
                """
            } catch {
                return "Unable to fetch storage info."
            }
        }
        return "Unavailable."
    }

    func fetchNetworkInfo() -> String {
        return "Network Status: Stable (Simulated)"
    }

    func fetchCPUUsage() -> String {
        return "CPU Usage: 30% (Simulated)"
    }

    func fetchRAMInfo() -> String {
        return "RAM Usage: 4 GB / 8 GB (Simulated)"
    }

    func fetchSensorInfo() -> String {
        return """
        Accelerometer: Available
        Gyroscope: Available
        """
    }

    func fetchCameraInfo() -> String {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera, .builtInTripleCamera],
            mediaType: .video,
            position: .unspecified
        )
        let cameras = discoverySession.devices.map { $0.localizedName }.joined(separator: ", ")
        return "Available Cameras: \(cameras)"
    }

    func saveReportsToUserDefaults() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(savedReports) {
            UserDefaults.standard.set(encoded, forKey: "SavedReports")
        }
    }

    static func loadSavedReports() -> [Report] {
        if let savedData = UserDefaults.standard.data(forKey: "SavedReports") {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode([Report].self, from: savedData) {
                return decoded
            }
        }
        return []
    }
}

struct Report: Identifiable, Codable {
    var id = UUID()
    let fileName: String
    let fileURL: URL
    let date: Date
}

struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct PDFPreviewView: View {
    let pdfURL: URL

    var body: some View {
        VStack {
            if let pdfDocument = PDFDocument(url: pdfURL) {
                PDFKitView(document: pdfDocument)
                    .edgesIgnoringSafeArea(.all)
            } else {
                Text("Failed to load PDF.")
                    .foregroundColor(.red)
            }
        }
        .navigationTitle("PDF Preview")
    }
}

struct PDFKitView: UIViewRepresentable {
    let document: PDFDocument

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = document
        pdfView.autoScales = true
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {}
}
