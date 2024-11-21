import SwiftUI

struct ModulesView: View {
    @Binding var modules: [Module]
    @Binding var activeModules: [Bool]

    var body: some View {
        VStack {
            Text("Manage Modules")
                .font(.headline)
                .padding(.top)

            List {
                ForEach(modules.indices, id: \.self) { index in
                    HStack {
                        Toggle(modules[index].name, isOn: $activeModules[index])
                        Spacer()
                        Image(systemName: "line.horizontal.3")
                            .foregroundColor(.gray)
                    }
                }
                .onMove { indices, newOffset in
                    modules.move(fromOffsets: indices, toOffset: newOffset)
                    activeModules.move(fromOffsets: indices, toOffset: newOffset)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .environment(\.editMode, .constant(.active))
        }
    }
}
