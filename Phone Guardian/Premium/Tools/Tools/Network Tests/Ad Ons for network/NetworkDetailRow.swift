//
//  NetworkDetailRow.swift
//  Phone Guardian
//
//  Created by Kevin Doyle Jr. on 12/9/24.
//


import SwiftUI

struct NetworkDetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text("\(label):")
                .bold()
            Spacer()
            Text(value)
                .foregroundColor(.gray)
        }
    }
}