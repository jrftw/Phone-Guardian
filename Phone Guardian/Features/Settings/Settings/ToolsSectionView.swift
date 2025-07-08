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
                        HStack(spacing: 10) {
                            Image(systemName: "speedometer")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.blue)
                            Text("Network Speed Test")
                                .font(.body)
                        }
                        .padding(.vertical, 5)
                    }
                    NavigationLink(destination: ScannerView()) {
                        HStack(spacing: 10) {
                            Image(systemName: "doc.text.viewfinder")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.blue)
                            Text("Scanner (PDF, Docs, etc.)")
                                .font(.body)
                        }
                        .padding(.vertical, 5)
                    }
                    NavigationLink(destination: DocumentConversionView()) {
                        HStack(spacing: 10) {
                            Image(systemName: "arrow.2.squarepath")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.blue)
                            Text("Document Conversion")
                                .font(.body)
                        }
                        .padding(.vertical, 5)
                    }
                    NavigationLink(destination: PrivateStorageView()) {
                        HStack(spacing: 10) {
                            Image(systemName: "lock.shield")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.blue)
                            Text("Private Storage for Files")
                                .font(.body)
                        }
                        .padding(.vertical, 5)
                    }
                }
            } else {
                Text("Unlock the Tools Add-on for just $2.99 and enjoy access to these powerful utilities:")
                    .font(.subheadline)

                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 10) {
                        Image(systemName: "speedometer")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.blue)
                        Text("Network Speed Test")
                            .font(.body)
                    }
                    .padding(.vertical, 5)
                    HStack(spacing: 10) {
                        Image(systemName: "doc.text.viewfinder")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.blue)
                        Text("Scanner (PDF, Docs, etc.)")
                            .font(.body)
                    }
                    .padding(.vertical, 5)
                    HStack(spacing: 10) {
                        Image(systemName: "arrow.2.squarepath")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.blue)
                        Text("Document Conversion")
                            .font(.body)
                    }
                    .padding(.vertical, 5)
                    HStack(spacing: 10) {
                        Image(systemName: "lock.shield")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.blue)
                        Text("Private Storage for Files")
                            .font(.body)
                    }
                    .padding(.vertical, 5)
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
