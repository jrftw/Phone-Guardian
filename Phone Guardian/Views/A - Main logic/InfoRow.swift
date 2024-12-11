import SwiftUI

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .bold()
            Spacer()
            Text(value)
        }
        .padding(.vertical, 5)
    }
}
