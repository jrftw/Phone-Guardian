// GoldSectionView.swift

import SwiftUI
import StoreKit

struct GoldSectionView: View {
    @ObservedObject var iapManager: IAPManager

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Gold")
                .font(.title2)
                .bold()

            if iapManager.hasGoldSubscription {
                Text("Gold Features Unlocked")
                    .font(.headline)
                    .foregroundColor(.green)
                    .padding(.bottom, 10)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Included in Gold:")
                        .font(.headline)

                    NavigationLink(destination: TestKitView()) {
                        FeatureRow(icon: "checkmark.seal", title: "Test Kit", description: "Run device diagnostics and privacy tests")
                    }
                    NavigationLink(destination: ReportsView()) {
                        FeatureRow(icon: "doc.text", title: "Export Reports to PDF", description: "Save and share detailed device reports")
                    }
                    NavigationLink(destination: NotificationsView()) {
                        FeatureRow(icon: "bell.badge", title: "Notification Kit", description: "Advanced privacy and security notifications")
                    }
                    NavigationLink(destination: UnlockPromptView(feature: "Clean Duplicates")) {
                        FeatureRow(icon: "trash.circle", title: "Clean Duplicates", description: "Find and remove duplicate files")
                    }
                }
            } else {
                Text("Unlock Gold for just $2.99 and enjoy premium features:")
                    .font(.subheadline)

                VStack(alignment: .leading, spacing: 8) {
                    FeatureRow(icon: "nosign", title: "Ad-Free Experience", description: "Enjoy the app with no ads")
                    FeatureRow(icon: "checkmark.seal", title: "Test Kit", description: "Run device diagnostics and privacy tests")
                    FeatureRow(icon: "doc.text", title: "Export Reports to PDF", description: "Save and share detailed device reports")
                    FeatureRow(icon: "bell.badge", title: "Notification Kit", description: "Advanced privacy and security notifications")
                    FeatureRow(icon: "trash.circle", title: "Clean Duplicates", description: "Find and remove duplicate files")
                }

                HStack {
                    Spacer()
                    Button(action: {
                        Task { await iapManager.purchaseGold() }
                    }) {
                        Text("Purchase Gold for $2.99")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    Spacer()
                }
                .padding(.top, 10)

                Button(action: {
                    Task { await iapManager.restorePurchases() }
                }) {
                    Text("Restore Purchases")
                        .foregroundColor(.blue)
                        .font(.body)
                        .padding(.top, 5)
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color(UIColor.black).opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
