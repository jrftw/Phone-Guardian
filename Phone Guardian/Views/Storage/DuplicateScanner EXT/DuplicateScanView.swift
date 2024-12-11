// DuplicateScanView.swift

import SwiftUI

struct DuplicateScanView: View {
    @ObservedObject var scanner = DuplicateScanner.shared
    @State private var showResultsScreen = false
    @SwiftUI.Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
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
        .fullScreenCover(isPresented: $showResultsScreen, onDismiss: {
            dismiss()
        }) {
            DuplicateResultsView()
        }
        .onAppear {
            scanner.startDuplicateScan()
        }
        .onChange(of: scanner.isScanning) { isScanning in
            if !isScanning {
                showResultsScreen = true
            }
        }
    }
}
