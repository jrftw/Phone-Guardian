// FeatureChoiceView.swift

import SwiftUI

struct FeatureChoiceView: View {
    let onChoose: (TemporaryFeature) -> Void
    var body: some View {
        VStack(spacing: 20) {
            Text("Choose a Feature to Unlock")
                .font(.title2)
                .bold()
                .foregroundColor(.white)
            Button {
                onChoose(.gold)
            } label: {
                Text("Unlock Gold for 7 Days")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.yellow)
                    .cornerRadius(8)
            }
            Button {
                onChoose(.tools)
            } label: {
                Text("Unlock Tools for 7 Days")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.black.opacity(0.8))
        .cornerRadius(12)
        .frame(maxWidth: 300)
        .ignoresSafeArea()
    }
}
