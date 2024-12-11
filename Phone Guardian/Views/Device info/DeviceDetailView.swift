import SwiftUI

struct DeviceDetailView: View {
    let device: Device

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(device.name)
                .font(.largeTitle)
                .bold()
            Text("Release Date: \(device.releaseDate)")
                .font(.subheadline)
                .foregroundColor(.gray)
            ForEach(device.specifications.sorted(by: >), id: \.key) { key, value in
                HStack {
                    Text("\(key):")
                        .bold()
                    Spacer()
                    Text(value)
                }
            }
            Spacer()
        }
        .padding()
        .navigationTitle(device.name)
    }
}

