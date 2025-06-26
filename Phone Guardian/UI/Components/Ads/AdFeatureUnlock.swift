// AdFeatureUnlock.swift

import Foundation

struct AdFeatureUnlock: Identifiable {
    let id = UUID()
    let featureName: String
    let completion: (Bool) -> Void
}
