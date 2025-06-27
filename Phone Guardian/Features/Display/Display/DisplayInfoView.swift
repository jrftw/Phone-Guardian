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
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                // Display Information Section
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "Display Information", icon: "display")
                    
                    LazyVStack(spacing: 8) {
                        ModernInfoRow(icon: "magnifyingglass", label: "Zoom", value: "Enabled", iconColor: .blue)
                        ModernInfoRow(icon: "rectangle.on.rectangle", label: "Screen Captured", value: isScreenCaptured() ? "Yes" : "No", iconColor: .orange)
                        ModernInfoRow(icon: "speedometer", label: "Frame Rate", value: "\(Int(frameRate)) FPS", iconColor: .green)
                    }
                }
                .modernCard()
                
                // Brightness Chart Section
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "Brightness Level", icon: "sun.max")
                    
                    BrightnessChart(brightness: brightness)
                        .frame(height: 200)
                        .modernCard(padding: 16)
                }
                
                // More Info Button
                Button(action: {
                    isMoreInfoPresented = true
                    logger.info("More Info button tapped.")
                }) {
                    HStack {
                        Image(systemName: "info.circle.fill")
                        Text("More Display Information")
                    }
                }
                .modernButton(backgroundColor: .blue)
                .sheet(isPresented: $isMoreInfoPresented) {
                    if #available(iOS 16.0, *) {
                        DisplayMoreInfoView()
                            .presentationDetents([.large])
                            .presentationDragIndicator(.visible)
                    } else {
                        DisplayMoreInfoView()
                    }
                }
            }
            .padding()
        }
        .background(Color(UIColor.systemBackground).ignoresSafeArea())
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

        // Get actual display refresh rate
        frameRate = getDisplayRefreshRate()
        logger.info("Display refresh rate: \(Int(frameRate)) FPS")
    }

    func stopMonitoringDisplay() {
        cancellable?.cancel()
        logger.info("Stopped monitoring display.")
    }

    // MARK: - Get Display Refresh Rate
    func getDisplayRefreshRate() -> Double {
        // Get the actual display refresh rate
        if #available(iOS 15.0, *) {
            return Double(UIScreen.main.maximumFramesPerSecond)
        } else {
            // Fallback for older iOS versions - use device capabilities
            let modelCode = DeviceCapabilities.getDeviceModelCode()
            
            // Check for ProMotion displays (120Hz)
            if modelCode.contains("iPhone13") && (modelCode.contains("Pro") || modelCode.contains("Max")) ||
               modelCode.contains("iPhone14") && (modelCode.contains("Pro") || modelCode.contains("Max")) ||
               modelCode.contains("iPhone15") && (modelCode.contains("Pro") || modelCode.contains("Max")) ||
               modelCode.contains("iPhone16") && (modelCode.contains("Pro") || modelCode.contains("Max")) {
                return 120.0
            } else {
                return 60.0
            }
        }
    }

    // MARK: - Check if Screen is Captured
    func isScreenCaptured() -> Bool {
        return UIScreen.main.isCaptured
    }
}

struct BrightnessChart: View {
    let brightness: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Brightness Level")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(Int(brightness))%")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: brightness, total: 100)
                .progressViewStyle(LinearProgressViewStyle(tint: brightness > 70 ? .red : brightness > 40 ? .orange : .green))
                .scaleEffect(y: 2)
        }
    }
}

struct DisplayMoreInfoView: View {
    @EnvironmentObject var iapManager: IAPManager
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 24) {
                    // Display Specifications Section
                    VStack(alignment: .leading, spacing: 16) {
                        ModernSectionHeader(title: "Display Specifications", icon: "display")
                        
                        LazyVStack(spacing: 8) {
                            ModernInfoRow(icon: "circle.lefthalf.filled", label: "OLED", value: "Yes", iconColor: .blue)
                            ModernInfoRow(icon: "eye", label: "Retina HD", value: "Yes", iconColor: .green)
                            ModernInfoRow(icon: "roundedrectangle", label: "Rounded Corners", value: "Yes", iconColor: .purple)
                            ModernInfoRow(icon: "scale.3d", label: "Render Scale", value: "2.0", iconColor: .orange)
                            ModernInfoRow(icon: "ruler", label: "Diagonal", value: "6.1 inches", iconColor: .red)
                            ModernInfoRow(icon: "aspectratio", label: "Screen Ratio", value: "19.5:9", iconColor: .cyan)
                            ModernInfoRow(icon: "rectangle", label: "Logical Resolution", value: "828 x 1792", iconColor: .indigo)
                            ModernInfoRow(icon: "rectangle.fill", label: "Physical Resolution", value: "1170 x 2532", iconColor: .pink)
                            ModernInfoRow(icon: "dot.radiowaves.left.and.right", label: "Pixel Density", value: "460 PPI", iconColor: .gray)
                            ModernInfoRow(icon: "speedometer", label: "Refresh Rate", value: "120 Hz", iconColor: .blue)
                        }
                    }
                    .modernCard()
                }
                .padding()
            }
            .background(Color(UIColor.systemBackground).ignoresSafeArea())
            .navigationTitle("Display Details")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
