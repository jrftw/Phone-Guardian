//
//  FooterView.swift
//  Phone Guardian
//
//  Created by Kevin Doyle Jr. on 11/23/24.
//

import SwiftUI

struct FooterView: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("Made in Pittsburgh, PA USA 🇺🇸🇺🇸")
                .font(.footnote)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)

            Text("Version 1.12 Build (1) © 2024 Infinitum Imagery LLC")
                .font(.footnote)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)

            Text("Made by @JrFTW all rights reserved.")
                .font(.footnote)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)

            HStack {
                Spacer()
                Link("Privacy Policy", destination: URL(string: "https://infinitumlive.com/phone-guardian-protect-privacy-policy/")!)
                    .font(.footnote)
                    .foregroundColor(.blue)
                Spacer()
                NavigationLink(destination: DisclaimerView()) {
                    Text("Disclaimer")
                        .font(.footnote)
                        .foregroundColor(.blue)
                }
                Spacer()
                Link("Terms of Service", destination: URL(string: "https://infinitumlive.com/apps-terms-of-service/")!)
                    .font(.footnote)
                    .foregroundColor(.blue)
                Spacer()
            }
            .padding(.bottom, 10)
        }
        .padding(.top, 10)
    }
}
