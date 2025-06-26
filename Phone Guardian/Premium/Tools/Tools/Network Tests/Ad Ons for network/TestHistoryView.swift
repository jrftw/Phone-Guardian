//
//  TestHistoryView.swift
//  Phone Guardian
//
//  Created by Kevin Doyle Jr. on 12/9/24.
//


import SwiftUI

struct TestHistoryView: View {
    let testHistory: [NetworkTestResult]

    var body: some View {
        List(testHistory) { result in
            VStack(alignment: .leading) {
                Text("Date: \(result.date, formatter: dateFormatter)")
                    .font(.headline)
                Text("Download: \(result.downloadSpeed) Mbps")
                Text("Upload: \(result.uploadSpeed) Mbps")
                Text("Ping: \(result.ping) ms")
            }
        }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }
}