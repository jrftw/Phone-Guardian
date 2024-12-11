import AppTrackingTransparency
import Foundation

struct TrackingPermissionHelper {
    static func requestTrackingPermission() {
        let hasRequestedTrackingPermission = UserDefaults.standard.bool(forKey: "HasRequestedTrackingPermission")

        // Only request if not already done
        if !hasRequestedTrackingPermission {
            if #available(iOS 14, *) {
                ATTrackingManager.requestTrackingAuthorization { status in
                    DispatchQueue.main.async {
                        switch status {
                        case .authorized:
                            print("Tracking authorized.")
                        case .denied:
                            print("Tracking denied.")
                        case .restricted:
                            print("Tracking restricted.")
                        case .notDetermined:
                            print("Tracking not determined.")
                        @unknown default:
                            print("Unknown status.")
                        }

                        // Mark the tracking prompt as shown
                        UserDefaults.standard.set(true, forKey: "HasRequestedTrackingPermission")
                    }
                }
            } else {
                print("ATT not supported on this iOS version.")
            }
        } else {
            print("Tracking permission already requested.")
        }
    }
}
