//
//  InfoRow.swift
//  Phone Guardian
//
//  Created by Kevin Doyle Jr. on 11/15/24.
//


import SwiftUI

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label).bold()
            Spacer()
            Text(value).foregroundColor(.gray)
        }
    }
}