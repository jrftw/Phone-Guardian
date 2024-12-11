// ToolsSectionView.swift

import SwiftUI
import StoreKit

struct ToolsSectionView: View {
    @ObservedObject var iapManager: IAPManager

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Tools")
                .font(.title2)
                .bold()

            if iapManager.hasToolsSubscription {
                Text("Tools Unlocked")
                    .font(.headline)
                    .foregroundColor(.green)
                    .padding(.bottom, 10)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Included in Tools:")
                        .font(.headline)

                    NavigationLink(destination: NetworkSpeedTestView()) {
                        FeatureRow(title: "Network Speed Test", icon: "speedometer")
                    }
                    NavigationLink(destination: ScannerView()) {
                        FeatureRow(title: "Scanner (PDF, Docs, etc.)", icon: "doc.text.viewfinder")
                    }
                    NavigationLink(destination: DocumentConversionView()) {
                        FeatureRow(title: "Document Conversion", icon: "arrow.2.squarepath")
                    }
                    NavigationLink(destination: PrivateStorageView()) {
                        FeatureRow(title: "Private Storage for Files", icon: "lock.shield")
                    }
                }
            } else {
                Text("Unlock the Tools Add-on for just $2.99 and enjoy access to these powerful utilities:")
                    .font(.subheadline)

                VStack(alignment: .leading, spacing: 8) {
                    FeatureRow(title: "Network Speed Test", icon: "speedometer")
                    FeatureRow(title: "Scanner (PDF, Docs, etc.)", icon: "doc.text.viewfinder")
                    FeatureRow(title: "Document Conversion", icon: "arrow.2.squarepath")
                    FeatureRow(title: "Private Storage for Files", icon: "lock.shield")
                }

                HStack {
                    Spacer()
                    Button(action: {
                        Task { await iapManager.purchaseTools() }
                    }) {
                        Text("Purchase Tools for $2.99")
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

struct FeatureRow: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(.blue)
            Text(title)
                .font(.body)
        }
        .padding(.vertical, 5)
    }
}
