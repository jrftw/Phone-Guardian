import SwiftUI
import os

struct ClearCacheView: View {
    @State private var showCleanupConfirmation = false
    @State private var progress: Double = 0.0
    @State private var isClearingCache = false
    @AppStorage("enableLogging") private var enableLogging = false
    private let logger = Logger(subsystem: "com.phoneguardian.storage", category: "ClearCacheView")

    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Text("Clear Cache")
                .font(.title)
                .bold()

            Text("Free up space by clearing cached and temporary files on your device.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()

            if isClearingCache {
                VStack(spacing: 10) {
                    ProgressView(value: progress, total: 1.0)
                        .progressViewStyle(LinearProgressViewStyle())
                        .padding()
                    Text("Clearing cache: \(Int(progress * 100))%")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
            } else if progress == 1.0 {
                Text("Cache cleared successfully!")
                    .font(.headline)
                    .foregroundColor(.green)
            }

            Button(action: {
                clearCacheAndTempFiles()
                logEvent("Clear Cache button tapped.")
            }) {
                Text(isClearingCache ? "Clearing..." : "Clear Cache & Temp Files")
                    .padding()
                    .background(isClearingCache ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(isClearingCache)

            Spacer()

            // Disclaimer Section
            Text("Disclaimer: Clearing cache may not reflect exact device conditions and depends on the device's resources.")
                .font(.footnote)
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
                .padding(.top, 10)
        }
        .padding()
        .sheet(isPresented: $showCleanupConfirmation) {
            CleanupConfirmationView()
        }
    }

    func clearCacheAndTempFiles() {
        isClearingCache = true
        progress = 0.0

        DispatchQueue.global(qos: .background).async {
            if let tempDirectory = FileManager.default.temporaryDirectory.path as String? {
                do {
                    let filePaths = try FileManager.default.contentsOfDirectory(atPath: tempDirectory)
                    let totalFiles = filePaths.count

                    guard totalFiles > 0 else {
                        DispatchQueue.main.async {
                            self.isClearingCache = false
                            self.progress = 1.0
                            self.showCleanupConfirmation = true
                            logger.info("No temporary files to clear.")
                        }
                        return
                    }

                    for (index, filePath) in filePaths.enumerated() {
                        try FileManager.default.removeItem(atPath: "\(tempDirectory)/\(filePath)")
                        // Update progress on the main thread
                        DispatchQueue.main.async {
                            self.progress = Double(index + 1) / Double(totalFiles)
                        }
                    }

                    DispatchQueue.main.async {
                        self.isClearingCache = false
                        self.progress = 1.0
                        self.showCleanupConfirmation = true
                        logger.info("Cache and temporary files cleared successfully.")
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.isClearingCache = false
                        logger.error("Failed to clear cache: \(error.localizedDescription)")
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.isClearingCache = false
                    logger.error("Temporary directory not found.")
                }
            }
        }
    }

    func logEvent(_ message: String) {
        if enableLogging {
            logger.info("\(message, privacy: .public)")
        }
    }
}
