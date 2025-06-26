// FeatureChoiceView.swift

import SwiftUI

enum ChosenFeature {
    case gold
    case tools
}

struct FeatureChoiceView: View {
    let onFeatureChosen: (ChosenFeature) -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 20) {
                Text("Choose a Feature to Unlock:")
                    .foregroundColor(.white)
                    .font(.title2)
                    .bold()
                Button {
                    onFeatureChosen(.gold)
                } label: {
                    Text("Unlock Gold (7 days)")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .cornerRadius(8)
                }
                Button {
                    onFeatureChosen(.tools)
                } label: {
                    Text("Unlock Tools (7 days)")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
    }
}
