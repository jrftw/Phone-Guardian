import SwiftUI

struct DashboardModule: Identifiable, Codable {
    let id: UUID
    let name: String
    var isEnabled: Bool
    var order: Int
}
