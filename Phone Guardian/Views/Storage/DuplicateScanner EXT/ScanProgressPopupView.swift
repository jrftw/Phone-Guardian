// ScanProgressPopupView.swift

import SwiftUI

struct ScanProgressPopupView: View {
    @ObservedObject var scanner: DuplicateScanner

    var body: some View {
        VStack(spacing: 20) {
            Text("Scanning for Duplicates")
                .font(.title2)
                .bold()

            ProgressView(value: scanner.progress)
                .progressViewStyle(LinearProgressViewStyle())
                .padding()

            Text("Current Task: \(scanner.currentTask)")
                .font(.headline)
                .foregroundColor(.blue)

            Text("\(Int(scanner.progress * 100))% Completed")
                .font(.subheadline)
                .foregroundColor(.gray)

            Text("Please do not leave this page until scanning is complete.")
                .font(.footnote)
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
                .padding(.top, 10)
        }
        .padding()
        .frame(maxWidth: 300)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 10)
    }
}
