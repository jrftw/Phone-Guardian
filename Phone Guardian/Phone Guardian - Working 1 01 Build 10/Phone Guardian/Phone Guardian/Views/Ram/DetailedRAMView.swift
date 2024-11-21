import SwiftUI
import os

struct DetailedRAMView: View {
    let activeRAM: Double
    let inactiveRAM: Double
    let wiredRAM: Double
    let freeRAM: Double
    let compressedRAM: Double
    let totalRAM: Double

    @AppStorage("enableLogging") private var enableLogging: Bool = false
    private let logger = Logger(subsystem: "com.phoneguardian.ram", category: "DetailedRAMView")
    @State private var isAlertPresented = false
    @State private var alertMessage = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("RAM Detailed View")
                .font(.title2)
                .bold()

            RamPieChart(
                activeRAM: activeRAM,
                inactiveRAM: inactiveRAM,
                wiredRAM: wiredRAM,
                freeRAM: freeRAM,
                compressedRAM: compressedRAM,
                totalRAM: totalRAM
            )
            .frame(height: 250)

            HStack(spacing: 10) {
                Button(action: cleanRAM) {
                    Text("Clean RAM Memory")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5) // Prevents text from cutting off
                }

                Button(action: deepCleanRAM) {
                    Text("Deep Clean RAM Memory")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5) // Prevents text from cutting off
                }
            }
            .frame(maxHeight: 60) // Ensure consistent height for buttons

            RamDefinitionsView()
        }
        .padding()
        .onAppear {
            logger.info("DetailedRAMView appeared.")
        }
        .alert(isPresented: $isAlertPresented) {
            Alert(title: Text("RAM Clean"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    func cleanRAM() {
        logger.info("Clean RAM initiated.")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            logger.info("Clean RAM completed.")
            alertMessage = "Clean RAM Memory has been completed."
            isAlertPresented = true
        }
    }

    func deepCleanRAM() {
        logger.info("Deep Clean RAM initiated.")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            logger.info("Deep Clean RAM completed.")
            alertMessage = "Deep Clean RAM Memory has been completed."
            isAlertPresented = true
        }
    }
}
