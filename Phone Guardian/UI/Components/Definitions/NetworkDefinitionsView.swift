//
//  NetworkDefinitionsView.swift
//  Phone Guardian
//
//  Created by Kevin Doyle Jr. on 11/23/24.
//


// NetworkDefinitionsView.swift

import SwiftUI

struct NetworkDefinitionsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            InfoRow(label: "Hotspot", value: "A personal connection tethered for sharing.")
            InfoRow(label: "VPN", value: "Virtual Private Network.")
        }
    }
}