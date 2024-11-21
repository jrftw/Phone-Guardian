import SwiftUI
import os

struct InfoRow: View {
    let label: String
    let value: String

    @AppStorage("enableLogging") private var enableLogging = false
    private let logger = Logger(subsystem: "com.phoneguardian.ui", category: "InfoRow")

    var body: some View {
        HStack {
            Text(label)
                .bold()
            Spacer()
            Text(value)
                .foregroundColor(.gray)
        }
        .onAppear {
            logInfo("Displaying InfoRow: \(label) - \(value)")
        }
    }

    private func logInfo(_ message: String) {
        if enableLogging {
            logger.info("\(message)")
        }
    }
}
