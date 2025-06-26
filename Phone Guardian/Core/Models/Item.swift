import Foundation

struct Item: Identifiable, Codable {
    var id = UUID() // Change from `let` to `var` if mutability is required
    var timestamp: Date
}
