// DocumentConversionManager.swift

import Foundation
import PDFKit
import AVFoundation
import UIKit
import os.log

class DocumentConversionManager {
    static func convertToPDF(inputURL: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        let pdfFileName = inputURL.deletingPathExtension().lastPathComponent + ".pdf"
        let pdfFileURL = FileManager.default.temporaryDirectory.appendingPathComponent(pdfFileName)

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let data = try Data(contentsOf: inputURL)
                let pdfDocument = PDFDocument()

                if let image = UIImage(data: data) {
                    if let pdfPage = PDFPage(image: image) {
                        pdfDocument.insert(pdfPage, at: 0)
                    } else {
                        throw NSError(domain: "com.phoneguardian.pdf", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to create PDF page from image"])
                    }
                } else if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.plain], documentAttributes: nil) {
                    let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
                    let renderer = UIGraphicsImageRenderer(size: pageRect.size)
                    let image = renderer.image { ctx in
                        UIColor.white.set()
                        ctx.fill(pageRect)
                        attributedString.draw(in: CGRect(x: 20, y: 20, width: pageRect.width - 40, height: pageRect.height - 40))
                    }
                    if let pdfPage = PDFPage(image: image) {
                        pdfDocument.insert(pdfPage, at: 0)
                    } else {
                        throw NSError(domain: "com.phoneguardian.pdf", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to create PDF page from text"])
                    }
                } else {
                    throw NSError(domain: "com.phoneguardian.pdf", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unsupported file format"])
                }

                if pdfDocument.write(to: pdfFileURL) {
                    DispatchQueue.main.async {
                        completion(.success(pdfFileURL))
                    }
                } else {
                    throw NSError(domain: "com.phoneguardian.pdf", code: 5, userInfo: [NSLocalizedDescriptionKey: "Failed to write PDF to file"])
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    static func convertToImage(inputURL: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        let imageFileName = inputURL.deletingPathExtension().lastPathComponent + ".png"
        let imageFileURL = FileManager.default.temporaryDirectory.appendingPathComponent(imageFileName)

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let data = try Data(contentsOf: inputURL)
                if let pdfDocument = PDFDocument(data: data), let page = pdfDocument.page(at: 0) {
                    let pageRect = page.bounds(for: .mediaBox)
                    let renderer = UIGraphicsImageRenderer(size: pageRect.size)
                    let image = renderer.image { ctx in
                        UIColor.white.set()
                        ctx.fill(pageRect)
                        page.draw(with: .mediaBox, to: ctx.cgContext)
                    }
                    if let imageData = image.pngData() {
                        try imageData.write(to: imageFileURL)
                        DispatchQueue.main.async {
                            completion(.success(imageFileURL))
                        }
                    } else {
                        throw NSError(domain: "com.phoneguardian.image", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to create image data"])
                    }
                } else {
                    throw NSError(domain: "com.phoneguardian.image", code: 2, userInfo: [NSLocalizedDescriptionKey: "Unsupported file format"])
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    static func convertToAudio(inputURL: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        let audioFileName = inputURL.deletingPathExtension().lastPathComponent + ".m4a"
        let audioFileURL = FileManager.default.temporaryDirectory.appendingPathComponent(audioFileName)

        Task.detached(priority: .userInitiated) {
            do {
                let asset = AVAsset(url: inputURL)
                try await export(asset: asset, to: audioFileURL, presetName: AVAssetExportPresetAppleM4A, outputFileType: .m4a)
                DispatchQueue.main.async {
                    completion(.success(audioFileURL))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    static func convertToVideo(inputURL: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        let videoFileName = inputURL.deletingPathExtension().lastPathComponent + ".mp4"
        let videoFileURL = FileManager.default.temporaryDirectory.appendingPathComponent(videoFileName)

        Task.detached(priority: .userInitiated) {
            do {
                let asset = AVAsset(url: inputURL)
                try await export(asset: asset, to: videoFileURL, presetName: AVAssetExportPresetHighestQuality, outputFileType: .mp4)
                DispatchQueue.main.async {
                    completion(.success(videoFileURL))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    private static func export(asset: AVAsset, to outputURL: URL, presetName: String, outputFileType: AVFileType) async throws {
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: presetName) else {
            throw NSError(domain: "com.phoneguardian.export", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to create export session"])
        }
        exportSession.outputURL = outputURL
        exportSession.outputFileType = outputFileType

        try await withCheckedThrowingContinuation { continuation in
            // Capture the export session in a way that's compatible with Sendable
            let session = exportSession
            session.exportAsynchronously {
                switch session.status {
                case .completed:
                    continuation.resume()
                case .failed, .cancelled:
                    continuation.resume(throwing: session.error ?? NSError(domain: "com.phoneguardian.export", code: 2, userInfo: [NSLocalizedDescriptionKey: "Unknown error"]))
                default:
                    break
                }
            }
        }
    }

    static func convertToZip(inputURL: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        let zipFileName = inputURL.deletingPathExtension().lastPathComponent + ".zip"
        let zipFileURL = FileManager.default.temporaryDirectory.appendingPathComponent(zipFileName)

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try ZipHelper.zipItem(at: inputURL, to: zipFileURL)
                DispatchQueue.main.async {
                    completion(.success(zipFileURL))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}
