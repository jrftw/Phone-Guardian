//
//  StorageInfoRow.swift
//  Phone Guardian
//
//  Created by Kevin Doyle Jr. on 12/9/24.
//


// StorageInfoRow.swift

import SwiftUI

struct StorageInfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundColor(.gray)
        }
    }
}