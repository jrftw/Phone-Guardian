import SwiftUI

struct ModuleListView: View {
    @Binding var modules: [Module]
    @Binding var isEditing: Bool

    var body: some View {
        ForEach(modules.indices, id: \.self) { index in
            HStack {
                if isEditing {
                    Image(systemName: "line.horizontal.3")
                        .foregroundColor(.gray)
                }
                Toggle(isOn: $modules[index].isEnabled) {
                    Text(modules[index].name)
                }
            }
        }
        .onMove { indices, newOffset in
            modules.move(fromOffsets: indices, toOffset: newOffset)
        }
    }
}
