//
//  VisionProModels.swift
//  Phone Guardian
//
//  Created by Kevin Doyle Jr. on 12/4/24.
//


//
//  VisionProModels.swift
//  Phone Guardian
//
//  Created by Kevin Doyle Jr. on 11/18/24.
//

import Foundation

// MARK: - Vision Pro Models Data

struct VisionProModels {
    static let models: [String: DeviceModel] = [
        "Vision1,1": DeviceModel(modelCode: "Vision1,1", modelName: "Apple Vision Pro", operatingSystem: "visionOS 1.0"),
        "Vision2,1": DeviceModel(modelCode: "Vision2,1", modelName: "Apple Vision Pro (2nd generation)", operatingSystem: "visionOS 2.0")
        // Add additional models as necessary
    ]
}