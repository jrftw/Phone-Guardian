//
//  DefinitionRow.swift
//  Phone Guardian
//
//  Created by Kevin Doyle Jr. on 11/18/24.
//


// DefinitionRow.swift
import SwiftUI

struct DefinitionRow: View {
    let term: String
    let definition: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(term)
                .bold()
            Text(definition)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}