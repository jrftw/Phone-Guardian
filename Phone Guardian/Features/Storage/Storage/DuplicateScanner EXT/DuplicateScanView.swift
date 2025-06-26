// DuplicateScanView.swift

import SwiftUI
import os

struct DuplicateScanView: View {
    @ObservedObject var scanner = DuplicateScanner.shared
    @State private var showResultsScreen = false
    @SwiftUI.Environment(\.dismiss) private var dismiss
    private let logger = Logger(subsystem: "com.phoneguardian.storage", category: "DuplicateScanView")

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Duplicate Scanner")
                    .font(.title)
                    .bold()
                Spacer()
            }
            .padding()
            .blur(radius: scanner.isScanning ? 3 : 0)
            .allowsHitTesting(!scanner.isScanning)
            if scanner.isScanning {
                ScanProgressPopupView(scanner: scanner)
            }
        }
        .background(Color(UIColor.systemBackground).ignoresSafeArea())
        .fullScreenCover(isPresented: $showResultsScreen, onDismiss: {
            dismiss()
        }) {
            DuplicateResultsView()
        }
        .onAppear {
            logger.info("DuplicateScanView appeared.")
            scanner.startDuplicateScan()
        }
        .onChange(of: scanner.isScanning) { isScanning in
            if !isScanning {
                showResultsScreen = true
            }
        }
    }
}
