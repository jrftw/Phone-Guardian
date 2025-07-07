import SwiftUI

struct ChangelogView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Upcoming Features")) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Referral Rewards")
                        Text("Ai+")
                        Text("Cloud+")
                        Text("Storage+")
                        Text("Privacy+")
                        Text("Modern Ui")
                        Text("+More")
                        
                    }
                }
                Section(header: Text("Version 1.13 - Builds 1")) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("**Build 1**:")
                        Text("• Bug Fixes")
                        
                    }
                }
                Section(header: Text("Version 1.12 - Builds 1")) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("**Build 1**:")
                        Text("• Bug Fixes")
                    }
                }

                Section(header: Text("Version 1.11 - Builds 1")) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("**Build 1**:")
                        Text("• Added the ability to obtain IDFA and IDFV Numbers")
                        Text("• Bug Fixes")
                    }
                }
                
                Section(header: Text("Version 1.10 - Builds 1")) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("**Build 1**:")
                        Text("• Fixed issue where Storage module would not load")
                    }
                }

                Section(header: Text("Version 1.09 - Builds 1 - 5")) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("**Build 1**:")
                        Text("• Bug fixes with face ID not being reconized on iPhone 15 Pro Max")
                        Text("**Build 2**:")
                        Text("• Bug fixes with ad not showing and unlocking features")
                        Text("**Build 3**:")
                        Text("• Bug fixes with watch ad not showing and unlocking features correctly")
                        Text("**Build 3**:") // As in original snippet, duplicate entry retained
                        Text("• Bug fixes & Stability improvements with watch ad not showing and unlocking features correctly on iPad OS")
                        Text("**Build 4**:")
                        Text("• Bug fixes & Stability improvements")
                        Text("**Build 5**:")
                        Text("• Bug fixes & Stability improvements")
                    }
                }

                Section(header: Text("Version 1.08 - Builds 1")) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("**Build 1**:")
                        Text("• Fixed Notification Issue")
                        Text("• Moved all the ad-ons to their own tab")
                    }
                }

                Section(header: Text("Version 1.07 - Builds 1 - 5")) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("**Build 1**:")
                        Text("• Fixed Device info to include all compatiable devices.")
                        Text("• Fixed Duplicate scanner issues.")

                        Text("**Build 2**:")
                        Text("• Fixed 5G, 4G and eSim issues.")

                        Text("**Build 3**:")
                        Text("• Fixed issues with network speed test.")
                        Text("• Fixed side bar issues when opening tools on iPadOS.")
                        Text("• Additional Bug fixes and improvments.")

                        Text("**Build 4**:")
                        Text("• Added Rating pop up")

                        Text("**Build 5**:")
                        Text("• Bug fixes")
                    }
                }

                Section(header: Text("Version 1.06 - Build 1 - 5")) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("**Build 1**:")
                        Text("• Implemented enhancements features.")

                        Text("**Build 2**:")
                        Text("• Removed non fuctioning features, fixed bugs.")

                        Text("**Build 3**:")
                        Text("• Bug fixes & Stablity.")

                        Text("**Build 4**:")
                        Text("• Bug fixes & Stablity.")

                        Text("**Build 5**:")
                        Text("• Bug fixes & Stablity.")
                        Text("• Removed references to ram cleaning.")
                    }
                }

                Section(header: Text("Version 1.05")) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("**Build 1**:")
                        Text("• Implemented enhancements features.")
                    }
                }

                Section(header: Text("Version 1.04")) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("**Builds 1 - 5**:")
                        Text("• Implemented enhancements features.")
                    }
                }

                Section(header: Text("Version 1.03 — Builds 1 to 6.3")) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("**Build 1**:")
                        Text("• Implemented enhancements features.")

                        Text("**Builds 2 - 6.3**:")
                        Text("• Bug Fixes")
                    }
                }

                Section(header: Text("Version 1.02 — Builds 1 to 7")) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("**Build 1**:")
                        Text("• Implemented the full Tools add-on section with fuctional logic")

                        Text("**Build 2**:")
                        Text("• Bug Fixes and UI Performace Improvements")

                        Text("**Build 3**:")
                        Text("• Bug Fixes and UI Performace Improvements")

                        Text("**Build 4**:")
                        Text("• Bug Fixes and UI Performace Improvements")

                        Text("**Build 5**:")
                        Text("• Bug Fixes and UI Performace Improvements")

                        Text("**Build 6**:")
                        Text("• Bug Fixes and UI Performace Improvements")

                        Text("**Build 7**:")
                        Text("• Bug Fixes and UI Performace Improvements")
                    }
                }

                Section(header: Text("Version 1.01 — Builds 1 to 18")) {
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
                        Text("• Introduced Gold features, including Deep Clean RAM.")
                        Text("• Resolved various bugs related to Gold feature implementation.")

                        Text("\n**Build 6**:")
                        Text("• Added persistent module toggle states in SettingsView.")
                        Text("• Optimized memory management in DashboardView.")
                        Text("• Adjusted footer behavior to remain static in SettingsView.")

                        Text("\n**Build 7**:")
                        Text("• Fixed AdBannerView layout issues on smaller devices.")
                        Text("• Enhanced purchase restoration logic for Gold features.")
                        Text("• Improved error logging for debugging purposes.")

                        Text("\n**Build 8**:")
                        Text("• Updated footer design to stay fixed at the bottom of SettingsView.")
                        Text("• Fixed navigation title to display 'Phone Guardian - Protect' consistently.")
                        Text("• Resolved app crashes caused by rapidly toggling modules.")

                        Text("\n**Build 9**:")
                        Text("• General bug fixes and stability improvements.")

                        Text("\n**Build 10**:")
                        Text("• Improved stability with additional minor bug fixes.")

                        Text("\n**Build 11**:")
                        Text("• Added support for new Tools subscription in SettingsView.")
                        Text("• Integrated persistent Tools subscription logic.")
                        Text("• Updated Tools section design to align with Gold's UI.")

                        Text("\n**Build 12**:")
                        Text("• Fixed crashes when accessing ToolsFeaturesView from the dashboard.")
                        Text("• Improved purchase process for Tools with better error handling.")

                        Text("\n**Build 13**:")
                        Text("• Added Document Conversion tools for ZIP, PDF, and DOCX.")
                        Text("• Improved descriptions and organization in the Tools section.")

                        Text("\n**Build 14**:")
                        Text("• Fixed issues with Tools subscription restoration syncing across devices.")
                        Text("• Redesigned ToolsFeaturesView with clearer icons and descriptions.")

                        Text("\n**Build 15**:")
                        Text("• Added Network Speed Test feature under Tools.")
                        Text("• Resolved layout issues in ScannerView when handling multiple documents.")

                        Text("\n**Build 16**:")
                        Text("• Introduced Private Storage for secure file management in Tools.")
                        Text("• Enhanced Tools section layout to align with the Gold section design.")

                        Text("\n**Build 17**:")
                        Text("• Fixed footer alignment issues in SettingsView across all devices.")
                        Text("• Improved error handling for invalid module toggle states.")

                        Text("\n**Build 18**:")
                        Text("• Added Tools icon to the bottom navigation bar upon subscription.")
                        Text("• Reordered bottom navigation to display Dashboard, Tools, Gold, and Settings.")
                        Text("• Improved module toggle persistence between app sessions.")
                        Text("• General stability and performance improvements.")
                    }
                }

                Section(header: Text("Version 1.00 — Initial Release")) {
                    Text("• Core functionality for displaying device, battery, CPU, RAM, and storage info.")
                    Text("• Integrated logging framework for debugging.")
                    Text("• Basic module visibility toggles in SettingsView.")
                    Text("• Initial DashboardView implementation.")
                }
            }
            .navigationTitle("Changelog")
            .listStyle(InsetGroupedListStyle())
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
