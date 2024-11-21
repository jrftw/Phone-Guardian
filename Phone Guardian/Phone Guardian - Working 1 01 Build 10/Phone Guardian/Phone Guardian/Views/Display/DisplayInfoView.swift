import SwiftUI
import os
import Combine

struct DisplayInfoView: View {
    @State private var frameRate: Double = 60.0
    @State private var brightness: Double = UIScreen.main.brightness * 100
    @State private var isMoreInfoPresented = false
    @State private var cancellable: AnyCancellable? = nil
    private let logger = Logger(subsystem: "com.phoneguardian.display", category: "DisplayInfoView")

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Display Information")
                .font(.title2)
                .bold()

            InfoRow(label: "Zoom", value: "Enabled")
            InfoRow(label: "Screen Captured", value: isScreenCaptured() ? "Yes" : "No")
            InfoRow(label: "Frame Rate", value: "\(Int(frameRate)) FPS")

            BrightnessChart(brightness: brightness)
                .frame(height: 200)

            Button(action: {
                isMoreInfoPresented = true
                logger.info("More Info button tapped.")
            }) {
                Text("More Info")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .sheet(isPresented: $isMoreInfoPresented) {
                DisplayMoreInfoView()
            }
        }
        .padding()
        .onAppear {
            logger.info("DisplayInfoView loaded.")
            startMonitoringDisplay()
        }
        .onDisappear {
            stopMonitoringDisplay()
        }
    }

    // MARK: - Monitor Display Updates
    func startMonitoringDisplay() {
        // Monitor screen brightness dynamically
        cancellable = Timer.publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                brightness = UIScreen.main.brightness * 100
                logger.info("Brightness updated to \(Int(brightness))%")
            }

        // Simulating frame rate monitoring (Replace with actual frame rate logic if available)
        Task {
            while true {
                try? await Task.sleep(nanoseconds: 1_000_000_000) // Wait for 1 second
                frameRate = Double.random(in: 30...120) // Simulate frame rate changes
                logger.info("Frame rate updated to \(Int(frameRate)) FPS")
            }
        }
    }

    func stopMonitoringDisplay() {
        cancellable?.cancel()
        logger.info("Stopped monitoring display.")
    }

    // MARK: - Check if Screen is Captured
    func isScreenCaptured() -> Bool {
        return UIScreen.main.isCaptured
    }
}

struct BrightnessChart: View {
    let brightness: Double

    var body: some View {
        ProgressView("Brightness", value: brightness, total: 100)
            .progressViewStyle(LinearProgressViewStyle(tint: brightness > 70 ? .red : .green))
    }
}

struct DisplayMoreInfoView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                InfoRow(label: "OLED", value: "Yes")
                InfoRow(label: "Retina HD", value: "Yes")
                InfoRow(label: "Rounded Corners", value: "Yes")
                InfoRow(label: "Render Scale", value: "2.0")
                InfoRow(label: "Diagonal", value: "6.1 inches")
                InfoRow(label: "Screen Ratio", value: "19.5:9")
                InfoRow(label: "Logical Resolution", value: "828 x 1792")
                InfoRow(label: "Physical Resolution", value: "1170 x 2532")
                InfoRow(label: "Pixel Density", value: "460 PPI")
                InfoRow(label: "Refresh Rate", value: "120 Hz")
            }
            .padding()
        }
    }
}
