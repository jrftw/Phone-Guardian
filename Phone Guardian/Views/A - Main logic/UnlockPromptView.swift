//
//  UnlockPromptView.swift
//  Phone Guardian
//
//  Created by Kevin Doyle Jr. on 12/16/24.
//


// UnlockPromptView.swift

import SwiftUI

struct UnlockPromptView: View {
    let feature: String

    var body: some View {
        VStack(spacing: 20) {
            Text("Unlock \(feature)")
                .font(.title)
                .bold()

            Text("This feature is available for Gold members only. Purchase Gold to unlock!")
                .multilineTextAlignment(.center)
                .padding()

            Button(action: {
                Task {
                    await IAPManager.shared.purchaseGold()
                }
            }) {
                Text("Purchase Gold")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.black.ignoresSafeArea())
        .foregroundColor(.white)
    }
}