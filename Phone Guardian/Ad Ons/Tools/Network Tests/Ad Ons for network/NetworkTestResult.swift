import Foundation

struct NetworkTestResult: Codable, Identifiable {
    let id: String
    let downloadSpeed: String
    let uploadSpeed: String
    let ping: String
    let date: Date
}
