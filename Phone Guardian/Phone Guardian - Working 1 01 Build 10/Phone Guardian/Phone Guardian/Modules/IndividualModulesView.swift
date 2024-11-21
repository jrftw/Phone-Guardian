import SwiftUI

struct IndividualModulesView: View {
    @Binding var modules: [Module]

    var body: some View {
        List {
            ForEach(modules) { module in
                NavigationLink(destination: module.view) {
                    Text(module.name)
                }
            }
        }
        .navigationTitle("Individual Modules")
    }
}
