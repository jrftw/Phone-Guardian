//
//  WatchModels.swift
//  Phone Guardian
//
//  Created by Kevin Doyle Jr. on 12/4/24.
//


//
//  WatchModels.swift
//  Phone Guardian
//
//  Created by Kevin Doyle Jr. on 11/18/24.
//

import Foundation

// MARK: - Apple Watch Models Data

struct WatchModels {
    static let models: [String: DeviceModel] = [
        "Watch4,1": DeviceModel(modelCode: "Watch4,1", modelName: "Apple Watch Series 4", operatingSystem: "watchOS 5"),
        "Watch4,2": DeviceModel(modelCode: "Watch4,2", modelName: "Apple Watch Series 4", operatingSystem: "watchOS 5"),
        "Watch5,1": DeviceModel(modelCode: "Watch5,1", modelName: "Apple Watch Series 5", operatingSystem: "watchOS 6"),
        "Watch5,2": DeviceModel(modelCode: "Watch5,2", modelName: "Apple Watch Series 5", operatingSystem: "watchOS 6"),
        "Watch5,3": DeviceModel(modelCode: "Watch5,3", modelName: "Apple Watch Series 5", operatingSystem: "watchOS 6"),
        "Watch5,4": DeviceModel(modelCode: "Watch5,4", modelName: "Apple Watch Series 5", operatingSystem: "watchOS 6"),
        "Watch5,9": DeviceModel(modelCode: "Watch5,9", modelName: "Apple Watch SE (1st generation)", operatingSystem: "watchOS 7"),
        "Watch5,10": DeviceModel(modelCode: "Watch5,10", modelName: "Apple Watch SE (1st generation)", operatingSystem: "watchOS 7"),
        "Watch6,1": DeviceModel(modelCode: "Watch6,1", modelName: "Apple Watch Series 6", operatingSystem: "watchOS 7"),
        "Watch6,2": DeviceModel(modelCode: "Watch6,2", modelName: "Apple Watch Series 6", operatingSystem: "watchOS 7"),
        "Watch6,6": DeviceModel(modelCode: "Watch6,6", modelName: "Apple Watch Series 7", operatingSystem: "watchOS 8"),
        "Watch6,7": DeviceModel(modelCode: "Watch6,7", modelName: "Apple Watch Series 7", operatingSystem: "watchOS 8"),
        "Watch6,10": DeviceModel(modelCode: "Watch6,10", modelName: "Apple Watch Series 8", operatingSystem: "watchOS 9"),
        "Watch6,11": DeviceModel(modelCode: "Watch6,11", modelName: "Apple Watch Series 8", operatingSystem: "watchOS 9"),
        "Watch6,14": DeviceModel(modelCode: "Watch6,14", modelName: "Apple Watch SE (2nd generation)", operatingSystem: "watchOS 9"),
        "Watch6,15": DeviceModel(modelCode: "Watch6,15", modelName: "Apple Watch SE (2nd generation)", operatingSystem: "watchOS 9"),
        "Watch6,18": DeviceModel(modelCode: "Watch6,18", modelName: "Apple Watch Ultra", operatingSystem: "watchOS 9")
        // Add additional models as necessary
    ]
}