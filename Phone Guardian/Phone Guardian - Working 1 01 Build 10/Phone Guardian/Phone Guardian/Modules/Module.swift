import SwiftUI

struct Module: Identifiable {
    let id = UUID()
    let name: String
    let view: AnyView
}
