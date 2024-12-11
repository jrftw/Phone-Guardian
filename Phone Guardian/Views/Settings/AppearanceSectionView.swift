//
//  AppearanceSectionView.swift
//  Phone Guardian
//
//  Created by Kevin Doyle Jr. on 11/23/24.
//

import SwiftUI

struct AppearanceSectionView: View {
    @Binding var appTheme: String

    var applyTheme: (String) -> Void

    var body: some View {
        Section(header: Text("Appearance")) {
            Picker("App Theme", selection: $appTheme) {
                Text("System").tag("system")
                Text("Light").tag("light")
                Text("Dark").tag("dark")
            }
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: appTheme) { newValue in
                applyTheme(newValue)
            }
        }
    }
}
