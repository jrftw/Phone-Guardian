//
//  ModelMapper.swift
//  Phone Guardian
//
//  Created by Kevin Doyle Jr. on 11/18/24.
//

import Foundation
import os.log

// MARK: - Device Model Mapper

struct ModelMapper {
    // MARK: - Map Model Code to Device Model

    static func mapModelCodeToDeviceModel(_ code: String) -> DeviceModel {
        let allModels: [String: DeviceModel] = iPhoneModels.models
            .merging(iPadModels.models) { (current, _) in current }
            .merging(MacModels.models) { (current, _) in current }
            .merging(WatchModels.models) { (current, _) in current }
            .merging(VisionProModels.models) { (current, _) in current }

        if let deviceModel = allModels[code] {
            os_log("Model code %{public}@ found: %{public}@", log: OSLog.default, type: .info, code, deviceModel.modelName)
            return deviceModel
        } else {
            os_log("Model code %{public}@ not found.", log: OSLog.default, type: .error, code)
            return DeviceModel(modelCode: code, modelName: "Unknown Model", operatingSystem: "Unknown OS")
        }
    }
}
