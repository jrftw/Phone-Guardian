// ZipHelper.swift

import Foundation
import ZIPFoundation
import os.log

class ZipHelper {
    static func zipItem(at sourceURL: URL, to destinationURL: URL) throws {
        let fileManager = FileManager.default

        do {
            try fileManager.zipItem(at: sourceURL, to: destinationURL)
        } catch {
            throw error
        }
    }
}
