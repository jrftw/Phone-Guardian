import Foundation
import Combine

final class LogManager: ObservableObject {
    static let shared = LogManager()
    @Published var logs: [String] = []

    private init() {}

    func addLog(_ log: String) {
        logs.append(log)
    }

    func clearLogs() {
        logs.removeAll()
    }
}
