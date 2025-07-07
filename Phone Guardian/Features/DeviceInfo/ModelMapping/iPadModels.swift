//
//  iPadModels.swift
//  Phone Guardian
//
//  Created by Kevin Doyle Jr. on 12/4/24.
//


//
//  iPadModels.swift
//  Phone Guardian
//
//  Created by Kevin Doyle Jr. on 11/18/24.
//

import Foundation

// MARK: - iPad Models Data

struct iPadModels {
    static let models: [String: DeviceModel] = [
        // Older iPads (2018-2020)
        "iPad6,11": DeviceModel(modelCode: "iPad6,11", modelName: "iPad (6th generation)", operatingSystem: "iOS 11.3"),
        "iPad6,12": DeviceModel(modelCode: "iPad6,12", modelName: "iPad (6th generation)", operatingSystem: "iOS 11.3"),
        "iPad8,1": DeviceModel(modelCode: "iPad8,1", modelName: "iPad Pro (11-inch) (1st generation)", operatingSystem: "iOS 12.1"),
        "iPad8,2": DeviceModel(modelCode: "iPad8,2", modelName: "iPad Pro (11-inch) (1st generation)", operatingSystem: "iOS 12.1"),
        "iPad8,3": DeviceModel(modelCode: "iPad8,3", modelName: "iPad Pro (11-inch) (1st generation)", operatingSystem: "iOS 12.1"),
        "iPad8,4": DeviceModel(modelCode: "iPad8,4", modelName: "iPad Pro (11-inch) (1st generation)", operatingSystem: "iOS 12.1"),
        "iPad8,5": DeviceModel(modelCode: "iPad8,5", modelName: "iPad Pro (12.9-inch) (4th generation)", operatingSystem: "iOS 12.1"),
        "iPad8,6": DeviceModel(modelCode: "iPad8,6", modelName: "iPad Pro (12.9-inch) (4th generation)", operatingSystem: "iOS 12.1"),
        "iPad8,7": DeviceModel(modelCode: "iPad8,7", modelName: "iPad Pro (12.9-inch) (4th generation)", operatingSystem: "iOS 12.1"),
        "iPad8,8": DeviceModel(modelCode: "iPad8,8", modelName: "iPad Pro (12.9-inch) (4th generation)", operatingSystem: "iOS 12.1"),
        "iPad8,9": DeviceModel(modelCode: "iPad8,9", modelName: "iPad Pro (11-inch) (2nd generation)", operatingSystem: "iOS 13.4"),
        "iPad8,10": DeviceModel(modelCode: "iPad8,10", modelName: "iPad Pro (11-inch) (2nd generation)", operatingSystem: "iOS 13.4"),
        "iPad8,11": DeviceModel(modelCode: "iPad8,11", modelName: "iPad Pro (12.9-inch) (5th generation)", operatingSystem: "iOS 13.4"),
        "iPad8,12": DeviceModel(modelCode: "iPad8,12", modelName: "iPad Pro (12.9-inch) (5th generation)", operatingSystem: "iOS 13.4"),
        
        // Current iPads (2020-2023)
        "iPad7,11": DeviceModel(modelCode: "iPad7,11", modelName: "iPad (7th generation)", operatingSystem: "iPadOS 13"),
        "iPad7,12": DeviceModel(modelCode: "iPad7,12", modelName: "iPad (7th generation)", operatingSystem: "iPadOS 13"),
        "iPad11,1": DeviceModel(modelCode: "iPad11,1", modelName: "iPad mini (5th generation)", operatingSystem: "iOS 12.2"),
        "iPad11,2": DeviceModel(modelCode: "iPad11,2", modelName: "iPad mini (5th generation)", operatingSystem: "iOS 12.2"),
        "iPad11,3": DeviceModel(modelCode: "iPad11,3", modelName: "iPad Air (3rd generation)", operatingSystem: "iOS 12.2"),
        "iPad11,4": DeviceModel(modelCode: "iPad11,4", modelName: "iPad Air (3rd generation)", operatingSystem: "iOS 12.2"),
        "iPad11,6": DeviceModel(modelCode: "iPad11,6", modelName: "iPad (8th generation)", operatingSystem: "iPadOS 14"),
        "iPad11,7": DeviceModel(modelCode: "iPad11,7", modelName: "iPad (8th generation)", operatingSystem: "iPadOS 14"),
        "iPad13,1": DeviceModel(modelCode: "iPad13,1", modelName: "iPad Air (4th generation)", operatingSystem: "iPadOS 14"),
        "iPad13,2": DeviceModel(modelCode: "iPad13,2", modelName: "iPad Air (4th generation)", operatingSystem: "iPadOS 14"),
        "iPad13,4": DeviceModel(modelCode: "iPad13,4", modelName: "iPad Pro (11-inch) (3rd generation)", operatingSystem: "iPadOS 14.5"),
        "iPad13,5": DeviceModel(modelCode: "iPad13,5", modelName: "iPad Pro (11-inch) (3rd generation)", operatingSystem: "iPadOS 14.5"),
        "iPad13,6": DeviceModel(modelCode: "iPad13,6", modelName: "iPad Pro (11-inch) (3rd generation)", operatingSystem: "iPadOS 14.5"),
        "iPad13,7": DeviceModel(modelCode: "iPad13,7", modelName: "iPad Pro (11-inch) (3rd generation)", operatingSystem: "iPadOS 14.5"),
        "iPad13,8": DeviceModel(modelCode: "iPad13,8", modelName: "iPad Pro (12.9-inch) (6th generation)", operatingSystem: "iPadOS 14.5"),
        "iPad13,9": DeviceModel(modelCode: "iPad13,9", modelName: "iPad Pro (12.9-inch) (6th generation)", operatingSystem: "iPadOS 14.5"),
        "iPad13,10": DeviceModel(modelCode: "iPad13,10", modelName: "iPad Pro (12.9-inch) (6th generation)", operatingSystem: "iPadOS 14.5"),
        "iPad13,11": DeviceModel(modelCode: "iPad13,11", modelName: "iPad Pro (12.9-inch) (6th generation)", operatingSystem: "iPadOS 14.5"),
        "iPad13,16": DeviceModel(modelCode: "iPad13,16", modelName: "iPad Air (5th generation)", operatingSystem: "iPadOS 15.4"),
        "iPad13,17": DeviceModel(modelCode: "iPad13,17", modelName: "iPad Air (5th generation)", operatingSystem: "iPadOS 15.4"),
        "iPad14,1": DeviceModel(modelCode: "iPad14,1", modelName: "iPad mini (6th generation)", operatingSystem: "iPadOS 15"),
        "iPad14,2": DeviceModel(modelCode: "iPad14,2", modelName: "iPad mini (6th generation)", operatingSystem: "iPadOS 15"),
        "iPad14,3": DeviceModel(modelCode: "iPad14,3", modelName: "iPad (9th generation)", operatingSystem: "iPadOS 15"),
        "iPad14,4": DeviceModel(modelCode: "iPad14,4", modelName: "iPad (9th generation)", operatingSystem: "iPadOS 15"),
        "iPad14,5": DeviceModel(modelCode: "iPad14,5", modelName: "iPad (10th generation)", operatingSystem: "iPadOS 16"),
        "iPad14,6": DeviceModel(modelCode: "iPad14,6", modelName: "iPad (10th generation)", operatingSystem: "iPadOS 16"),
        
        // Newer iPads (2024-2025)
        "iPad15,1": DeviceModel(modelCode: "iPad15,1", modelName: "iPad Air (6th generation)", operatingSystem: "iPadOS 17.4"),
        "iPad15,2": DeviceModel(modelCode: "iPad15,2", modelName: "iPad Air (6th generation)", operatingSystem: "iPadOS 17.4"),
        "iPad15,3": DeviceModel(modelCode: "iPad15,3", modelName: "iPad Pro (11-inch) (4th generation)", operatingSystem: "iPadOS 17.4"),
        "iPad15,4": DeviceModel(modelCode: "iPad15,4", modelName: "iPad Pro (11-inch) (4th generation)", operatingSystem: "iPadOS 17.4"),
        "iPad15,5": DeviceModel(modelCode: "iPad15,5", modelName: "iPad Pro (12.9-inch) (7th generation)", operatingSystem: "iPadOS 17.4"),
        "iPad15,6": DeviceModel(modelCode: "iPad15,6", modelName: "iPad Pro (12.9-inch) (7th generation)", operatingSystem: "iPadOS 17.4"),
        "iPad16,1": DeviceModel(modelCode: "iPad16,1", modelName: "iPad (11th generation)", operatingSystem: "iPadOS 17.4"),
        "iPad16,2": DeviceModel(modelCode: "iPad16,2", modelName: "iPad (11th generation)", operatingSystem: "iPadOS 17.4"),
        
        // Future iPad models (placeholder for upcoming releases)
        "iPad16,3": DeviceModel(modelCode: "iPad16,3", modelName: "iPad mini (7th generation)", operatingSystem: "iPadOS 18"),
        "iPad16,4": DeviceModel(modelCode: "iPad16,4", modelName: "iPad mini (7th generation)", operatingSystem: "iPadOS 18"),
        "iPad16,5": DeviceModel(modelCode: "iPad16,5", modelName: "iPad Air (7th generation)", operatingSystem: "iPadOS 18"),
        "iPad16,6": DeviceModel(modelCode: "iPad16,6", modelName: "iPad Air (7th generation)", operatingSystem: "iPadOS 18")
    ]
}