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
        // Older Intel Macs (2018-2020)
        "MacBookAir8,1": DeviceModel(modelCode: "MacBookAir8,1", modelName: "MacBook Air (13-inch, 2018)", operatingSystem: "macOS 10.14"),
        "MacBookAir8,2": DeviceModel(modelCode: "MacBookAir8,2", modelName: "MacBook Air (13-inch, 2019)", operatingSystem: "macOS 10.14.5"),
        "MacBookAir9,1": DeviceModel(modelCode: "MacBookAir9,1", modelName: "MacBook Air (13-inch, 2020)", operatingSystem: "macOS 10.15.3"),
        "MacBookPro15,1": DeviceModel(modelCode: "MacBookPro15,1", modelName: "MacBook Pro (15-inch, 2018)", operatingSystem: "macOS 10.14"),
        "MacBookPro15,2": DeviceModel(modelCode: "MacBookPro15,2", modelName: "MacBook Pro (13-inch, 2018)", operatingSystem: "macOS 10.14"),
        "MacBookPro15,3": DeviceModel(modelCode: "MacBookPro15,3", modelName: "MacBook Pro (15-inch, 2019)", operatingSystem: "macOS 10.14.5"),
        "MacBookPro15,4": DeviceModel(modelCode: "MacBookPro15,4", modelName: "MacBook Pro (13-inch, 2019)", operatingSystem: "macOS 10.14.5"),
        "MacBookPro16,1": DeviceModel(modelCode: "MacBookPro16,1", modelName: "MacBook Pro (16-inch, 2019)", operatingSystem: "macOS 10.15.1"),
        "MacBookPro16,2": DeviceModel(modelCode: "MacBookPro16,2", modelName: "MacBook Pro (13-inch, 2020)", operatingSystem: "macOS 10.15.3"),
        "MacBookPro16,3": DeviceModel(modelCode: "MacBookPro16,3", modelName: "MacBook Pro (13-inch, 2020)", operatingSystem: "macOS 10.15.3"),
        "MacBookPro16,4": DeviceModel(modelCode: "MacBookPro16,4", modelName: "MacBook Pro (13-inch, 2020)", operatingSystem: "macOS 10.15.3"),
        "iMac19,1": DeviceModel(modelCode: "iMac19,1", modelName: "iMac (27-inch, 2019)", operatingSystem: "macOS 10.14.5"),
        "iMac19,2": DeviceModel(modelCode: "iMac19,2", modelName: "iMac (21.5-inch, 2019)", operatingSystem: "macOS 10.14.5"),
        "iMac20,1": DeviceModel(modelCode: "iMac20,1", modelName: "iMac (27-inch, 2020)", operatingSystem: "macOS 10.15.6"),
        "iMac20,2": DeviceModel(modelCode: "iMac20,2", modelName: "iMac (21.5-inch, 2020)", operatingSystem: "macOS 10.15.6"),
        "Macmini8,1": DeviceModel(modelCode: "Macmini8,1", modelName: "Mac mini (2018)", operatingSystem: "macOS 10.14"),
        "MacPro7,1": DeviceModel(modelCode: "MacPro7,1", modelName: "Mac Pro (2019)", operatingSystem: "macOS 10.15.1"),
        
        // Apple Silicon Macs (M1 Series - 2020-2022)
        "MacBookAir10,1": DeviceModel(modelCode: "MacBookAir10,1", modelName: "MacBook Air (M1, 2020)", operatingSystem: "macOS 11.0"),
        "MacBookPro17,1": DeviceModel(modelCode: "MacBookPro17,1", modelName: "MacBook Pro (13-inch, M1, 2020)", operatingSystem: "macOS 11.0"),
        "Mac14,2": DeviceModel(modelCode: "Mac14,2", modelName: "iMac (24-inch, M1, 2021)", operatingSystem: "macOS 11.3"),
        "Mac14,3": DeviceModel(modelCode: "Mac14,3", modelName: "iMac (24-inch, M1, 2021)", operatingSystem: "macOS 11.3"),
        "Mac14,4": DeviceModel(modelCode: "Mac14,4", modelName: "iMac (24-inch, M1, 2021)", operatingSystem: "macOS 11.3"),
        "Mac14,5": DeviceModel(modelCode: "Mac14,5", modelName: "iMac (24-inch, M1, 2021)", operatingSystem: "macOS 11.3"),
        "Mac14,6": DeviceModel(modelCode: "Mac14,6", modelName: "Mac mini (M1, 2020)", operatingSystem: "macOS 11.0"),
        "Mac14,7": DeviceModel(modelCode: "Mac14,7", modelName: "Mac Studio (M1 Max/Ultra, 2022)", operatingSystem: "macOS 12.3"),
        "Mac14,8": DeviceModel(modelCode: "Mac14,8", modelName: "Mac Studio (M1 Max/Ultra, 2022)", operatingSystem: "macOS 12.3"),
        "Mac14,9": DeviceModel(modelCode: "Mac14,9", modelName: "Mac Studio (M1 Max/Ultra, 2022)", operatingSystem: "macOS 12.3"),
        "Mac14,10": DeviceModel(modelCode: "Mac14,10", modelName: "Mac Studio (M1 Max/Ultra, 2022)", operatingSystem: "macOS 12.3"),
        "Mac14,11": DeviceModel(modelCode: "Mac14,11", modelName: "Mac Studio (M1 Max/Ultra, 2022)", operatingSystem: "macOS 12.3"),
        "Mac14,12": DeviceModel(modelCode: "Mac14,12", modelName: "Mac Studio (M1 Max/Ultra, 2022)", operatingSystem: "macOS 12.3"),
        
        // Apple Silicon Macs (M1 Pro/Max Series - 2021-2022)
        "MacBookPro18,1": DeviceModel(modelCode: "MacBookPro18,1", modelName: "MacBook Pro (16-inch, M1 Pro/Max, 2021)", operatingSystem: "macOS 12.0"),
        "MacBookPro18,2": DeviceModel(modelCode: "MacBookPro18,2", modelName: "MacBook Pro (16-inch, M1 Pro/Max, 2021)", operatingSystem: "macOS 12.0"),
        "MacBookPro18,3": DeviceModel(modelCode: "MacBookPro18,3", modelName: "MacBook Pro (14-inch, M1 Pro/Max, 2021)", operatingSystem: "macOS 12.0"),
        "MacBookPro18,4": DeviceModel(modelCode: "MacBookPro18,4", modelName: "MacBook Pro (14-inch, M1 Pro/Max, 2021)", operatingSystem: "macOS 12.0"),
        
        // Apple Silicon Macs (M2 Series - 2022-2023)
        "MacBookAir10,2": DeviceModel(modelCode: "MacBookAir10,2", modelName: "MacBook Air (M2, 2022)", operatingSystem: "macOS 12.0"),
        "MacBookAir10,3": DeviceModel(modelCode: "MacBookAir10,3", modelName: "MacBook Air (15-inch, M2, 2023)", operatingSystem: "macOS 13.0"),
        "MacBookPro18,5": DeviceModel(modelCode: "MacBookPro18,5", modelName: "MacBook Pro (13-inch, M2, 2022)", operatingSystem: "macOS 13.0"),
        "MacBookPro18,6": DeviceModel(modelCode: "MacBookPro18,6", modelName: "MacBook Pro (16-inch, M2 Pro/Max, 2023)", operatingSystem: "macOS 13.0"),
        "MacBookPro18,7": DeviceModel(modelCode: "MacBookPro18,7", modelName: "MacBook Pro (14-inch, M2 Pro/Max, 2023)", operatingSystem: "macOS 13.0"),
        "Mac14,15": DeviceModel(modelCode: "Mac14,15", modelName: "Mac mini (M2, 2023)", operatingSystem: "macOS 13.0"),
        "Mac14,16": DeviceModel(modelCode: "Mac14,16", modelName: "Mac mini (M2 Pro, 2023)", operatingSystem: "macOS 13.0"),
        "Mac14,17": DeviceModel(modelCode: "Mac14,17", modelName: "Mac Studio (M2 Max/Ultra, 2023)", operatingSystem: "macOS 13.2"),
        "Mac14,18": DeviceModel(modelCode: "Mac14,18", modelName: "Mac Studio (M2 Max/Ultra, 2023)", operatingSystem: "macOS 13.2"),
        "Mac14,19": DeviceModel(modelCode: "Mac14,19", modelName: "Mac Studio (M2 Max/Ultra, 2023)", operatingSystem: "macOS 13.2"),
        "Mac14,20": DeviceModel(modelCode: "Mac14,20", modelName: "Mac Studio (M2 Max/Ultra, 2023)", operatingSystem: "macOS 13.2"),
        "Mac14,21": DeviceModel(modelCode: "Mac14,21", modelName: "Mac Studio (M2 Max/Ultra, 2023)", operatingSystem: "macOS 13.2"),
        "Mac14,22": DeviceModel(modelCode: "Mac14,22", modelName: "Mac Studio (M2 Max/Ultra, 2023)", operatingSystem: "macOS 13.2"),
        "Mac14,23": DeviceModel(modelCode: "Mac14,23", modelName: "Mac Studio (M2 Max/Ultra, 2023)", operatingSystem: "macOS 13.2"),
        "Mac14,24": DeviceModel(modelCode: "Mac14,24", modelName: "Mac Studio (M2 Max/Ultra, 2023)", operatingSystem: "macOS 13.2"),
        
        // Apple Silicon Macs (M3 Series - 2024-2025)
        "MacBookAir15,1": DeviceModel(modelCode: "MacBookAir15,1", modelName: "MacBook Air (M3, 2024)", operatingSystem: "macOS 14.1"),
        "MacBookAir15,2": DeviceModel(modelCode: "MacBookAir15,2", modelName: "MacBook Air (M3, 2024)", operatingSystem: "macOS 14.1"),
        "MacBookPro18,8": DeviceModel(modelCode: "MacBookPro18,8", modelName: "MacBook Pro (14-inch, M3 Pro/Max, 2024)", operatingSystem: "macOS 14.1"),
        "MacBookPro18,9": DeviceModel(modelCode: "MacBookPro18,9", modelName: "MacBook Pro (14-inch, M3 Pro/Max, 2024)", operatingSystem: "macOS 14.1"),
        "MacBookPro18,10": DeviceModel(modelCode: "MacBookPro18,10", modelName: "MacBook Pro (16-inch, M3 Pro/Max, 2024)", operatingSystem: "macOS 14.1"),
        "MacBookPro18,11": DeviceModel(modelCode: "MacBookPro18,11", modelName: "MacBook Pro (16-inch, M3 Pro/Max, 2024)", operatingSystem: "macOS 14.1"),
        "Mac15,1": DeviceModel(modelCode: "Mac15,1", modelName: "iMac (M3, 2024)", operatingSystem: "macOS 14.1"),
        "Mac15,2": DeviceModel(modelCode: "Mac15,2", modelName: "iMac (M3, 2024)", operatingSystem: "macOS 14.1"),
        "Mac15,3": DeviceModel(modelCode: "Mac15,3", modelName: "iMac (M3, 2024)", operatingSystem: "macOS 14.1"),
        "Mac15,4": DeviceModel(modelCode: "Mac15,4", modelName: "iMac (M3, 2024)", operatingSystem: "macOS 14.1"),
        "Mac15,5": DeviceModel(modelCode: "Mac15,5", modelName: "Mac mini (M3, 2024)", operatingSystem: "macOS 14.1"),
        "Mac15,6": DeviceModel(modelCode: "Mac15,6", modelName: "Mac mini (M3 Pro, 2024)", operatingSystem: "macOS 14.1"),
        "Mac15,7": DeviceModel(modelCode: "Mac15,7", modelName: "Mac Studio (M3 Max/Ultra, 2024)", operatingSystem: "macOS 14.1"),
        "Mac15,8": DeviceModel(modelCode: "Mac15,8", modelName: "Mac Studio (M3 Max/Ultra, 2024)", operatingSystem: "macOS 14.1"),
        "Mac15,9": DeviceModel(modelCode: "Mac15,9", modelName: "Mac Studio (M3 Max/Ultra, 2024)", operatingSystem: "macOS 14.1"),
        "Mac15,10": DeviceModel(modelCode: "Mac15,10", modelName: "Mac Studio (M3 Max/Ultra, 2024)", operatingSystem: "macOS 14.1"),
        "Mac15,11": DeviceModel(modelCode: "Mac15,11", modelName: "Mac Studio (M3 Max/Ultra, 2024)", operatingSystem: "macOS 14.1"),
        "Mac15,12": DeviceModel(modelCode: "Mac15,12", modelName: "Mac Studio (M3 Max/Ultra, 2024)", operatingSystem: "macOS 14.1"),
        "Mac15,13": DeviceModel(modelCode: "Mac15,13", modelName: "Mac Studio (M3 Max/Ultra, 2024)", operatingSystem: "macOS 14.1"),
        "Mac15,14": DeviceModel(modelCode: "Mac15,14", modelName: "Mac Studio (M3 Max/Ultra, 2024)", operatingSystem: "macOS 14.1"),
        
        // Future Mac models (placeholder for upcoming releases)
        "Mac16,1": DeviceModel(modelCode: "Mac16,1", modelName: "MacBook Air (M4, 2025)", operatingSystem: "macOS 15"),
        "Mac16,2": DeviceModel(modelCode: "Mac16,2", modelName: "MacBook Pro (M4 Pro/Max, 2025)", operatingSystem: "macOS 15"),
        "Mac16,3": DeviceModel(modelCode: "Mac16,3", modelName: "iMac (M4, 2025)", operatingSystem: "macOS 15"),
        "Mac16,4": DeviceModel(modelCode: "Mac16,4", modelName: "Mac mini (M4, 2025)", operatingSystem: "macOS 15"),
        "Mac16,5": DeviceModel(modelCode: "Mac16,5", modelName: "Mac Studio (M4 Max/Ultra, 2025)", operatingSystem: "macOS 15")
    ]
}