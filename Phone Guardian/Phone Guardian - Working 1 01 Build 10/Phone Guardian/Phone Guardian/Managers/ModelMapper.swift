//
//  ModelMapper.swift
//  Phone Guardian
//
//  Created by Kevin Doyle Jr. on 11/18/24.
//

import Foundation

struct DeviceModel {
    let modelCode: String
    let modelName: String
    let operatingSystem: String
}

struct ModelMapper {
    static func mapModelCodeToDeviceModel(_ code: String) -> DeviceModel {
        let modelMapping: [String: DeviceModel] = [
            // MARK: - iPhone Models
            "iPhone8,1": DeviceModel(modelCode: "iPhone8,1", modelName: "iPhone 6s", operatingSystem: "iOS 9"),
            "iPhone8,2": DeviceModel(modelCode: "iPhone8,2", modelName: "iPhone 6s Plus", operatingSystem: "iOS 9"),
            "iPhone8,4": DeviceModel(modelCode: "iPhone8,4", modelName: "iPhone SE (1st generation)", operatingSystem: "iOS 9.3"),
            "iPhone9,1": DeviceModel(modelCode: "iPhone9,1", modelName: "iPhone 7", operatingSystem: "iOS 10"),
            "iPhone9,2": DeviceModel(modelCode: "iPhone9,2", modelName: "iPhone 7 Plus", operatingSystem: "iOS 10"),
            "iPhone9,3": DeviceModel(modelCode: "iPhone9,3", modelName: "iPhone 7", operatingSystem: "iOS 10"),
            "iPhone9,4": DeviceModel(modelCode: "iPhone9,4", modelName: "iPhone 7 Plus", operatingSystem: "iOS 10"),
            "iPhone10,1": DeviceModel(modelCode: "iPhone10,1", modelName: "iPhone 8", operatingSystem: "iOS 11"),
            "iPhone10,2": DeviceModel(modelCode: "iPhone10,2", modelName: "iPhone 8 Plus", operatingSystem: "iOS 11"),
            "iPhone10,3": DeviceModel(modelCode: "iPhone10,3", modelName: "iPhone X", operatingSystem: "iOS 11"),
            "iPhone10,4": DeviceModel(modelCode: "iPhone10,4", modelName: "iPhone 8", operatingSystem: "iOS 11"),
            "iPhone10,5": DeviceModel(modelCode: "iPhone10,5", modelName: "iPhone 8 Plus", operatingSystem: "iOS 11"),
            "iPhone10,6": DeviceModel(modelCode: "iPhone10,6", modelName: "iPhone X", operatingSystem: "iOS 11"),
            "iPhone11,2": DeviceModel(modelCode: "iPhone11,2", modelName: "iPhone XS", operatingSystem: "iOS 12"),
            "iPhone11,4": DeviceModel(modelCode: "iPhone11,4", modelName: "iPhone XS Max", operatingSystem: "iOS 12"),
            "iPhone11,6": DeviceModel(modelCode: "iPhone11,6", modelName: "iPhone XS Max", operatingSystem: "iOS 12"),
            "iPhone11,8": DeviceModel(modelCode: "iPhone11,8", modelName: "iPhone XR", operatingSystem: "iOS 12"),
            "iPhone12,1": DeviceModel(modelCode: "iPhone12,1", modelName: "iPhone 11", operatingSystem: "iOS 13"),
            "iPhone12,3": DeviceModel(modelCode: "iPhone12,3", modelName: "iPhone 11 Pro", operatingSystem: "iOS 13"),
            "iPhone12,5": DeviceModel(modelCode: "iPhone12,5", modelName: "iPhone 11 Pro Max", operatingSystem: "iOS 13"),
            "iPhone12,8": DeviceModel(modelCode: "iPhone12,8", modelName: "iPhone SE (2nd generation)", operatingSystem: "iOS 13.4"),
            "iPhone13,1": DeviceModel(modelCode: "iPhone13,1", modelName: "iPhone 12 mini", operatingSystem: "iOS 14.1"),
            "iPhone13,2": DeviceModel(modelCode: "iPhone13,2", modelName: "iPhone 12", operatingSystem: "iOS 14.1"),
            "iPhone13,3": DeviceModel(modelCode: "iPhone13,3", modelName: "iPhone 12 Pro", operatingSystem: "iOS 14.1"),
            "iPhone13,4": DeviceModel(modelCode: "iPhone13,4", modelName: "iPhone 12 Pro Max", operatingSystem: "iOS 14.1"),
            "iPhone14,2": DeviceModel(modelCode: "iPhone14,2", modelName: "iPhone 13 Pro", operatingSystem: "iOS 15"),
            "iPhone14,3": DeviceModel(modelCode: "iPhone14,3", modelName: "iPhone 13 Pro Max", operatingSystem: "iOS 15"),
            "iPhone14,4": DeviceModel(modelCode: "iPhone14,4", modelName: "iPhone 13 mini", operatingSystem: "iOS 15"),
            "iPhone14,5": DeviceModel(modelCode: "iPhone14,5", modelName: "iPhone 13", operatingSystem: "iOS 15"),
            "iPhone14,6": DeviceModel(modelCode: "iPhone14,6", modelName: "iPhone SE (3rd generation)", operatingSystem: "iOS 15.4"),
            "iPhone14,7": DeviceModel(modelCode: "iPhone14,7", modelName: "iPhone 14", operatingSystem: "iOS 16"),
            "iPhone14,8": DeviceModel(modelCode: "iPhone14,8", modelName: "iPhone 14 Plus", operatingSystem: "iOS 16"),
            "iPhone15,2": DeviceModel(modelCode: "iPhone15,2", modelName: "iPhone 14 Pro", operatingSystem: "iOS 16"),
            "iPhone15,3": DeviceModel(modelCode: "iPhone15,3", modelName: "iPhone 14 Pro Max", operatingSystem: "iOS 16"),
            "iPhone15,4": DeviceModel(modelCode: "iPhone15,4", modelName: "iPhone 15", operatingSystem: "iOS 17"),
            "iPhone15,5": DeviceModel(modelCode: "iPhone15,5", modelName: "iPhone 15 Plus", operatingSystem: "iOS 17"),
            "iPhone16,1": DeviceModel(modelCode: "iPhone16,1", modelName: "iPhone 15 Pro", operatingSystem: "iOS 17"),
            "iPhone16,2": DeviceModel(modelCode: "iPhone16,2", modelName: "iPhone 15 Pro Max", operatingSystem: "iOS 17"),
            "iPhone17,1": DeviceModel(modelCode: "iPhone17,1", modelName: "iPhone 16 Pro", operatingSystem: "iOS 18"),
            "iPhone17,2": DeviceModel(modelCode: "iPhone17,2", modelName: "iPhone 16 Pro Max", operatingSystem: "iOS 18"),
            "iPhone17,3": DeviceModel(modelCode: "iPhone17,3", modelName: "iPhone 16", operatingSystem: "iOS 18"),
            "iPhone17,4": DeviceModel(modelCode: "iPhone17,4", modelName: "iPhone 16 Plus", operatingSystem: "iOS 18"),
            // Add additional models as necessary

            // MARK: - iPad Models
            "iPad7,11": DeviceModel(modelCode: "iPad7,11", modelName: "iPad (7th generation)", operatingSystem: "iPadOS 13"),
            "iPad7,12": DeviceModel(modelCode: "iPad7,12", modelName: "iPad (7th generation)", operatingSystem: "iPadOS 13"),
            "iPad8,1": DeviceModel(modelCode: "iPad8,1", modelName: "iPad Pro (11-inch)", operatingSystem: "iOS 12.1"),
            "iPad8,2": DeviceModel(modelCode: "iPad8,2", modelName: "iPad Pro (11-inch)", operatingSystem: "iOS 12.1"),
            "iPad8,3": DeviceModel(modelCode: "iPad8,3", modelName: "iPad Pro (11-inch)", operatingSystem: "iOS 12.1"),
            "iPad8,4": DeviceModel(modelCode: "iPad8,4", modelName: "iPad Pro (11-inch)", operatingSystem: "iOS 12.1"),
            "iPad8,5": DeviceModel(modelCode: "iPad8,5", modelName: "iPad Pro (12.9-inch) (3rd generation)", operatingSystem: "iOS 12.1"),
            "iPad8,6": DeviceModel(modelCode: "iPad8,6", modelName: "iPad Pro (12.9-inch) (3rd generation)", operatingSystem: "iOS 12.1"),
            "iPad8,7": DeviceModel(modelCode: "iPad8,7", modelName: "iPad Pro (12.9-inch) (3rd generation)", operatingSystem: "iOS 12.1"),
            "iPad8,8": DeviceModel(modelCode: "iPad8,8", modelName: "iPad Pro (12.9-inch) (3rd generation)", operatingSystem: "iOS 12.1"),
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
            "iPad13,8": DeviceModel(modelCode: "iPad13,8", modelName: "iPad Pro (12.9-inch) (5th generation)", operatingSystem: "iPadOS 14.5"),
            "iPad13,9": DeviceModel(modelCode: "iPad13,9", modelName: "iPad Pro (12.9-inch) (5th generation)", operatingSystem: "iPadOS 14.5"),
            "iPad13,10": DeviceModel(modelCode: "iPad13,10", modelName: "iPad Pro (12.9-inch) (5th generation)", operatingSystem: "iPadOS 14.5"),
            "iPad13,11": DeviceModel(modelCode: "iPad13,11", modelName: "iPad Pro (12.9-inch) (5th generation)", operatingSystem: "iPadOS 14.5"),
            "iPad13,16": DeviceModel(modelCode: "iPad13,16", modelName: "iPad Air (5th generation)", operatingSystem: "iPadOS 15.4"),
            "iPad13,17": DeviceModel(modelCode: "iPad13,17", modelName: "iPad Air (5th generation)", operatingSystem: "iPadOS 15.4"),
            "iPad14,1": DeviceModel(modelCode: "iPad14,1", modelName: "iPad mini (6th generation)", operatingSystem: "iPadOS 15"),
            "iPad14,2": DeviceModel(modelCode: "iPad14,2", modelName: "iPad mini (6th generation)", operatingSystem: "iPadOS 15"),
            "iPad14,3": DeviceModel(modelCode: "iPad14,3", modelName: "iPad (9th generation)", operatingSystem: "iPadOS 15"),
            "iPad14,4": DeviceModel(modelCode: "iPad14,4", modelName: "iPad (9th generation)", operatingSystem: "iPadOS 15"),
            "iPad14,5": DeviceModel(modelCode: "iPad14,5", modelName: "iPad (10th generation)", operatingSystem: "iPadOS 16"),
            "iPad14,6": DeviceModel(modelCode: "iPad14,6", modelName: "iPad (10th generation)", operatingSystem: "iPadOS 16"),
            // Add additional models as necessary

            // MARK: - Apple Watch Models
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
            "Watch6,18": DeviceModel(modelCode: "Watch6,18", modelName: "Apple Watch Ultra", operatingSystem: "watchOS 9"),
            // Add additional models as necessary

            // MARK: - Mac Models
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
            "Mac14,12": DeviceModel(modelCode: "Mac14,12", modelName: "Mac mini (M2, 2023)", operatingSystem: "macOS 13.0"),
            // Add additional models as necessary

            // MARK: - Vision Pro
            "Vision1,1": DeviceModel(modelCode: "Vision1,1", modelName: "Apple Vision Pro", operatingSystem: "visionOS 1.0"),
            "Vision2,1": DeviceModel(modelCode: "Vision2,1", modelName: "Apple Vision Pro (2nd generation)", operatingSystem: "visionOS 2.0")
        ]

        if let deviceModel = modelMapping[code] {
            return deviceModel
        } else {
            return DeviceModel(modelCode: code, modelName: "Unknown Model", operatingSystem: "Unknown OS")
        }
    }
}
