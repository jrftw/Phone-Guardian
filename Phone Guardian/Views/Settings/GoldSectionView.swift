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
                        FeatureRow(title: "Test Kit", icon: "checkmark.seal")
                    }
                    NavigationLink(destination: ReportsView()) {
                        FeatureRow(title: "Export Reports to PDF", icon: "doc.text")
                    }
                    NavigationLink(destination: NotificationsView()) {
                        FeatureRow(title: "Notification Kit", icon: "bell.badge")
                    }
                    NavigationLink(destination: UnlockPromptView(feature: "Clean Duplicates")) {
                        FeatureRow(title: "Clean Duplicates", icon: "trash.circle")
                    }
                }
            } else {
                Text("Unlock Gold for just $2.99 and enjoy premium features:")
                    .font(.subheadline)

                VStack(alignment: .leading, spacing: 8) {
                    FeatureRow(title: "Ad-Free Experience", icon: "nosign")
                    FeatureRow(title: "Test Kit", icon: "checkmark.seal")
                    FeatureRow(title: "Export Reports to PDF", icon: "doc.text")
                    FeatureRow(title: "Notification Kit", icon: "bell.badge")
                    FeatureRow(title: "Clean Duplicates", icon: "trash.circle")
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
