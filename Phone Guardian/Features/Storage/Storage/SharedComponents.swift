// CleanupConfirmationView.swift

import SwiftUI

struct CleanupConfirmationView: View {
    var body: some View {
        VStack {
            Text("Cleanup Completed!")
                .font(.title2)
                .padding()

            Text("Cache and temporary files have been successfully cleared.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()

            Spacer()
        }
        .padding()
    }
}
