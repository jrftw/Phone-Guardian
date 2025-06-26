// TrackingPermissionHelper.swift

import AppTrackingTransparency
import Foundation

struct TrackingPermissionHelper {
    static func requestTrackingPermission() {
        let hasRequestedTrackingPermission = UserDefaults.standard.bool(forKey: "HasRequestedTrackingPermission")
        if !hasRequestedTrackingPermission {
            if #available(iOS 14, *) {
                ATTrackingManager.requestTrackingAuthorization { status in
                    DispatchQueue.main.async {
                        switch status {
                        case .authorized: break
                        case .denied: break
                        case .restricted: break
                        case .notDetermined: break
                        @unknown default: break
                        }
                        UserDefaults.standard.set(true, forKey: "HasRequestedTrackingPermission")
                    }
                }
            }
        }
    }
}
