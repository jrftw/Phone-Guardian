//
//  DisclaimerView.swift
//  Phone Guardian
//
//  Created by Kevin Doyle Jr. on 11/28/24.
//


//
//  DisclaimerView.swift
//  Phone Guardian
//
//  Created by Kevin Doyle Jr. on 11/23/24.
//

import SwiftUI

struct DisclaimerView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Text("Disclaimer")
                    .font(.title2)
                    .bold()
                    .padding(.bottom, 10)

                Text("The features and functionality provided by Phone Guardian are designed to improve your device management experience. However, some features may be simulated or limited by system constraints.")
                    .font(.body)
                    .multilineTextAlignment(.leading)

                Text("Important Notes:")
                    .font(.headline)
                    .padding(.top, 5)

                Text("""
                - Certain features function based on resources available on your device and may not reflect exact conditions at all times.
                - RAM cleaning and cache clearing processes are influenced by Apple’s system requirements and restrictions, and results may vary across devices.
                - Device diagnostics and performance improvement metrics are provided for informational purposes and rely on available APIs and device compatibility.
                - We ensure compliance with Apple’s guidelines, and any simulated or estimated functionality is indicated clearly within the app.
                """)
                    .font(.body)
                    .multilineTextAlignment(.leading)

                Text("By using this app, you acknowledge and agree that results are dependent on your device's current state and system configurations.")
                    .font(.body)
                    .padding(.top, 10)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Disclaimer")
    }
}