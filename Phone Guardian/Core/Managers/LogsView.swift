import SwiftUI

struct LogsView: View {
    @ObservedObject private var logManager = LogManager.shared

    var body: some View {
        List {
            ForEach(logManager.logs, id: \.self) { log in
                Text(log)
                    .font(.footnote)
                    .padding(4)
            }
        }
        .navigationTitle("Logs")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Clear Logs") {
                    logManager.clearLogs()
                }
            }
        }
    }
}
