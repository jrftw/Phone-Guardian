//
//  VirusScannerView.swift
//  Phone Guardian
//
//  Created by Kevin Doyle Jr. on 11/19/24.
//

import SwiftUI

struct VirusScannerView: View {
    @State private var scanning = false
    @State private var scanResults: String = "No scan performed yet."
    
    var body: some View {
        VStack {
            if scanning {
                ProgressView("Scanning for viruses...")
                    .padding()
            } else {
                Text(scanResults)
                    .padding()
            }

            Button(action: startScan) {
                Text("Start Scan")
                    .foregroundColor(.white)
                    .padding()
                    .background(scanning ? Color.gray : Color.red)
                    .cornerRadius(8)
            }
            .disabled(scanning)
            .padding()
        }
        .navigationTitle("Virus Scanner")
    }

    private func startScan() {
        scanning = true
        scanResults = "Scanning system files..."

        // Simulate a scan with a random delay between 5 and 15 seconds
        let randomDelay = Double.random(in: 5...15)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + randomDelay) {
            scanning = false
            scanResults = "Scan Complete, no viruses found."
        }
    }
}
