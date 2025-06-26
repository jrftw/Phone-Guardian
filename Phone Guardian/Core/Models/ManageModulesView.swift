// ManageModulesView.swift

import SwiftUI

struct ManageModulesView: View {
    @EnvironmentObject var moduleManager: ModuleManager

    var body: some View {
        List {
            ForEach($moduleManager.modules) { $module in
                Toggle(isOn: $module.isEnabled) {
                    Text(module.name)
                }
                .onChange(of: module.isEnabled) { _ in
                    moduleManager.saveModules()
                }
            }
        }
        .navigationTitle("Manage Modules")
    }
}
