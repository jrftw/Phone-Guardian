// Environment.swift

// PGEnvironment.swift

// PGEnvironment.swift

import Foundation

struct PGEnvironment {
    static var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }

    static var isTestFlight: Bool {
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL {
            return appStoreReceiptURL.lastPathComponent == "sandboxReceipt"
        }
        return false
    }
}

struct PGEnvironmentConfig {
    static var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }

    static var isTestFlight: Bool {
        guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL else { return false }
        return appStoreReceiptURL.lastPathComponent == "sandboxReceipt"
    }
}

struct PGAppEnvironment {
    static var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }

    static var isTestFlight: Bool {
        guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL else { return false }
        return appStoreReceiptURL.lastPathComponent == "sandboxReceipt"
    }
}
