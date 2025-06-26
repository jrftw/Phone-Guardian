//
//  DefinitionsView.swift
//  Phone Guardian
//
//  Created by Kevin Doyle Jr. on 11/20/24.
//

import SwiftUI

struct DefinitionsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            DefinitionRow(term: "User Usage", definition: "The percentage of CPU used by user processes.")
            DefinitionRow(term: "System Usage", definition: "The percentage of CPU used by system processes.")
            DefinitionRow(term: "Idle Usage", definition: "The percentage of CPU that is currently not in use.")
            DefinitionRow(term: "Efficiency Cores", definition: "CPU cores optimized for low power consumption tasks.")
            DefinitionRow(term: "Performance Cores", definition: "CPU cores optimized for high-performance tasks.")
            DefinitionRow(term: "L1 Cache", definition: "A small amount of fast memory located near the CPU for quick data access.")
            DefinitionRow(term: "L2 Cache", definition: "A larger but slower cache for holding frequently used data.")
        }
    }
}
