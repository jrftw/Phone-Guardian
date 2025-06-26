import SwiftUI

struct CameraInfoView: View {
    var body: some View {
        VStack(spacing: 16) {
            // Title
            Text("Camera Information")
                .font(.title2)
                .bold()
                .padding(.top)

            // Camera Information
            VStack(alignment: .leading, spacing: 10) {
                InfoRow(label: "Telephoto Sensor", value: "Available")
                InfoRow(label: "LiDAR", value: "Available")
                InfoRow(label: "Wide Sensor", value: "Available")
                InfoRow(label: "Ultra-Wide Sensor", value: "Available")
                InfoRow(label: "Flashlight", value: "Available")
            }
            .padding(.horizontal)

            // More Info Button
            NavigationLink(destination: DetailedCameraInfoView()) { // Navigate to a detailed view
                Text("More Info")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding()
        .navigationTitle("Phone Guardian - Protect Information")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(UIColor.systemBackground))
    }
}

struct DetailedCameraInfoView: View {
    @EnvironmentObject var iapManager: IAPManager
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if !(iapManager.hasGoldSubscription || iapManager.hasToolsSubscription || iapManager.hasRemoveAds) {
                    AdBannerView()
                        .frame(height: 50)
                        .padding(.vertical)
                }
                Text("Detailed Camera Information")
                    .font(.title)
                    .bold()
                    .padding()

                Text("This section provides detailed insights about your camera hardware and features.")
                    .font(.body)
                    .padding(.horizontal)

                VStack(alignment: .leading, spacing: 10) {
                    Text("**Telephoto Sensor**:")
                    Text("Allows capturing images with optical zoom, providing greater detail for distant subjects.")

                    Text("**LiDAR**:")
                    Text("Used for depth sensing, enabling better AR experiences and low-light photography.")

                    Text("**Wide Sensor**:")
                    Text("Standard camera sensor for capturing everyday photos and videos.")

                    Text("**Ultra-Wide Sensor**:")
                    Text("Captures a broader field of view, ideal for landscapes or group shots.")

                    Text("**Flashlight**:")
                    Text("Built-in torch used for illumination in low-light conditions.")
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Detailed Info")
        .navigationBarTitleDisplayMode(.inline)
    }
}
