// GeneralSectionView.swift

import SwiftUI

struct GeneralSectionView: View {
    @Binding var updateFrequency: Double
    @Binding var enableLogging: Bool

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Update Frequency")
                Spacer()
                Text("\(Int(updateFrequency))s")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Slider(value: $updateFrequency, in: 2...10, step: 1)

            HStack {
                Text("Enable Logging")
                Spacer()
                Toggle("", isOn: $enableLogging)
                    .labelsHidden()
            }
        }
    }
}
