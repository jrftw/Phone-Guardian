// Environment.swift

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
        guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL else { return false }
        return appStoreReceiptURL.lastPathComponent == "sandboxReceipt"
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
