//
//  MacModels.swift
//  Phone Guardian
//
//  Created by Kevin Doyle Jr. on 12/4/24.
//


//
//  MacModels.swift
//  Phone Guardian
//
//  Created by Kevin Doyle Jr. on 11/18/24.
//

import Foundation

// MARK: - Mac Models Data

struct MacModels {
    static let models: [String: DeviceModel] = [
        "MacBookAir10,1": DeviceModel(modelCode: "MacBookAir10,1", modelName: "MacBook Air (M1, 2020)", operatingSystem: "macOS 11.0"),
        "MacBookAir10,2": DeviceModel(modelCode: "MacBookAir10,2", modelName: "MacBook Air (M2, 2022)", operatingSystem: "macOS 12.0"),
        "MacBookAir10,3": DeviceModel(modelCode: "MacBookAir10,3", modelName: "MacBook Air (15-inch, M2, 2023)", operatingSystem: "macOS 13.0"),
        "MacBookPro17,1": DeviceModel(modelCode: "MacBookPro17,1", modelName: "MacBook Pro (13-inch, M1, 2020)", operatingSystem: "macOS 11.0"),
        "MacBookPro18,1": DeviceModel(modelCode: "MacBookPro18,1", modelName: "MacBook Pro (16-inch, M1 Pro/Max, 2021)", operatingSystem: "macOS 12.0"),
        "MacBookPro18,2": DeviceModel(modelCode: "MacBookPro18,2", modelName: "MacBook Pro (16-inch, M1 Pro/Max, 2021)", operatingSystem: "macOS 12.0"),
        "MacBookPro18,3": DeviceModel(modelCode: "MacBookPro18,3", modelName: "MacBook Pro (14-inch, M1 Pro/Max, 2021)", operatingSystem: "macOS 12.0"),
        "MacBookPro18,4": DeviceModel(modelCode: "MacBookPro18,4", modelName: "MacBook Pro (14-inch, M1 Pro/Max, 2021)", operatingSystem: "macOS 12.0"),
        "MacBookPro18,5": DeviceModel(modelCode: "MacBookPro18,5", modelName: "MacBook Pro (13-inch, M2, 2022)", operatingSystem: "macOS 13.0"),
        "MacBookPro18,6": DeviceModel(modelCode: "MacBookPro18,6", modelName: "MacBook Pro (16-inch, M2 Pro/Max, 2023)", operatingSystem: "macOS 13.0"),
        "MacBookPro18,7": DeviceModel(modelCode: "MacBookPro18,7", modelName: "MacBook Pro (14-inch, M2 Pro/Max, 2023)", operatingSystem: "macOS 13.0"),
        "Mac14,2": DeviceModel(modelCode: "Mac14,2", modelName: "iMac (24-inch, M1, 2021)", operatingSystem: "macOS 11.3"),
        "Mac14,7": DeviceModel(modelCode: "Mac14,7", modelName: "Mac Studio (M1 Max/Ultra, 2022)", operatingSystem: "macOS 12.3"),
        "Mac14,12": DeviceModel(modelCode: "Mac14,12", modelName: "Mac mini (M2, 2023)", operatingSystem: "macOS 13.0")
        // Add additional models as necessary
    ]
}