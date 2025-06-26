import Foundation

struct Device: Identifiable {
    let id = UUID()
    let name: String
    let releaseDate: String
    let specifications: [String: String]
}
