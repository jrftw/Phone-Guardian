// RamDefinitionsView.swift
import SwiftUI

struct RamDefinitionsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            DefinitionRow(term: "Active RAM", definition: "Memory currently in use or recently used.")
            DefinitionRow(term: "Inactive RAM", definition: "Memory not actively used but contains data.")
            DefinitionRow(term: "Wired RAM", definition: "Memory that cannot be paged out to disk.")
            DefinitionRow(term: "Compressed RAM", definition: "Memory that has been compressed to save space.")
            DefinitionRow(term: "Free RAM", definition: "Memory that is not being used.")
        }
    }
}
