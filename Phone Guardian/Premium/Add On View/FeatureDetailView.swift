// FeatureDetailView.swift

import SwiftUI

struct FeatureDetailView: View {
    let featureName: String

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Text(featureName)
                .font(.title)
                .foregroundColor(.white)
        }
    }
}
