// IndividualModulesView.swift

import SwiftUI

struct IndividualModulesView: View {
    @EnvironmentObject var moduleManager: ModuleManager
    @EnvironmentObject var iapManager: IAPManager

    var body: some View {
        List {
            ForEach(moduleManager.modules) { module in
                NavigationLink(destination: module.view.navigationTitle(module.name)) {
                    Text(module.name)
                }
            }
        }
        .navigationTitle("Individual Modules")
    }
}

