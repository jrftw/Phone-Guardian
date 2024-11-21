import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome to Phone Guardian")
                    .font(.largeTitle)
                    .padding()

                NavigationLink("Camera Info", destination: CameraInfoView())
                    .padding()

                NavigationLink("Logs", destination: LogsView())
                    .padding()
            }
        }
        .navigationTitle("Home")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
