import SwiftUI

struct DowndetectorView: View {
    var body: some View {
        WebView(url: URL(string: "https://downdetector.com")!)
            .navigationTitle("Downdetector")
            .edgesIgnoringSafeArea(.all)
    }
}
