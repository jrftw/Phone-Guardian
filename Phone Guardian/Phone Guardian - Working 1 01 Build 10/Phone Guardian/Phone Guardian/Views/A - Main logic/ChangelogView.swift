//
//  ChangelogView.swift
//  Phone Guardian
//
//  Created by Kevin Doyle Jr. on 11/19/24.
//

import SwiftUI

struct ChangelogView: View {
    var body: some View {
        List {
            Section(header: Text("Version 1.02 — Builds 1")) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("**Build 1**:")
                    Text("• In progress")
                }
            }

            Section(header: Text("Version 1.01 — Builds 1 to 8")) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("**Build 1**:")
                    Text("• Added dynamic reordering of modules in Settings.")
                    Text("• Fixed alignment and UI issues in DashboardView.")
                    Text("• Initial implementation of persistent module order.")

                    Text("\n**Build 2**:")
                    Text("• Corrected battery usage chart bug causing blank space.")
                    Text("• Fixed module toggle delay in SettingsView.")
                    Text("• Enhanced logging for debugging purposes.")

                    Text("\n**Build 3**:")
                    Text("• Added 'Other' section in SettingsView.")
                    Text("• Integrated changelog view, feedback link, and social links.")
                    Text("• Improved footer design in SettingsView.")

                    Text("\n**Build 4**:")
                    Text("• Optimized RAM cleaning features.")
                    Text("• Fixed issues with Clean RAM on Startup options.")
                    Text("• General performance improvements and bug fixes.")

                    Text("\n**Build 5**:")
                    Text("• Bug fixes & Added Gold features.")

                    Text("\n**Build 6**:")
                    Text("• Added persistent module toggles in Settings.")
                    Text("• Improved memory management for DashboardView.")
                    Text("• Adjusted footer behavior to remain static in SettingsView.")

                    Text("\n**Build 7**:")
                    Text("• Fixed AdBannerView layout issues in smaller devices.")
                    Text("• Enhanced purchase restoration logic for Gold features.")
                    Text("• Improved error logging and debugging outputs.")

                    Text("\n**Build 8**:")
                    Text("• Updated footer design to always stay fixed at the bottom.")
                    Text("• Fixed navigation title to display 'Phone Guardian - Protect' consistently.")
                    Text("• Resolved crashing issues when toggling modules rapidly.")
                    
                    Text("\n**Build 9**:")
                    Text("• Bug Fixes")
                  
                    Text("\n**Build 10**:")
                    Text("• Bug Fixes & Stability improvements")
                }
            }

            Section(header: Text("Version 1.00 — Initial Release")) {
                Text("• Core functionality for displaying device, battery, CPU, RAM, and storage info.")
                Text("• Logging framework integration.")
                Text("• Basic module visibility toggles in SettingsView.")
                Text("• Initial DashboardView implementation.")
            }
        }
        .navigationTitle("Changelog")
        .listStyle(InsetGroupedListStyle())
    }
}
