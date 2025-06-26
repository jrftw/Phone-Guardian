// MARK: LOG: STORAGE
import Foundation
import Photos
import AVFoundation
import SwiftUI
import os

class MediaLibraryAnalyzerManager: ObservableObject {
    static let shared = MediaLibraryAnalyzerManager()
    private let logger = Logger(subsystem: "com.phoneguardian.medialibraryanalyzer", category: "MediaLibraryAnalyzerManager")
    
    @Published var mediaItems: [MediaItem] = []
    @Published var mediaCategories: [MediaCategory] = []
    @Published var mediaStatistics: MediaStatistics = MediaStatistics()
    @Published var analysisStatus: AnalysisStatus = .idle
    @Published var lastAnalysisDate: Date?
    
    enum AnalysisStatus {
        case idle, analyzing, completed, error, permissionDenied
    }
    
    struct MediaItem: Identifiable {
        let id = UUID()
        let assetID: String
        let fileName: String
        let fileSize: UInt64
        let mediaType: MediaType
        let format: String
        let creationDate: Date?
        let modificationDate: Date?
        let lastAccessedDate: Date?
        let duration: TimeInterval?
        let dimensions: CGSize?
        let location: CLLocation?
        let isFavorite: Bool
        let isHidden: Bool
        
        enum MediaType {
            case photo, video, audio, unknown
        }
        
        var formattedFileSize: String {
            return MediaLibraryAnalyzerManager.formatBytes(fileSize)
        }
        
        var formattedDuration: String {
            guard let duration = duration else { return "N/A" }
            let minutes = Int(duration) / 60
            let seconds = Int(duration) % 60
            return String(format: "%d:%02d", minutes, seconds)
        }
        
        var formattedDimensions: String {
            guard let dimensions = dimensions else { return "N/A" }
            return String(format: "%.0f x %.0f", dimensions.width, dimensions.height)
        }
    }
    
    struct MediaCategory: Identifiable {
        let id = UUID()
        let name: String
        let mediaType: MediaItem.MediaType
        let totalSize: UInt64
        let itemCount: Int
        let items: [MediaItem]
        
        var formattedTotalSize: String {
            return MediaLibraryAnalyzerManager.formatBytes(totalSize)
        }
    }
    
    struct MediaStatistics {
        var totalItems: Int = 0
        var totalSize: UInt64 = 0
        var itemsByType: [MediaItem.MediaType: Int] = [:]
        var sizeByType: [MediaItem.MediaType: UInt64] = [:]
        var itemsByFormat: [String: Int] = [:]
        var sizeByFormat: [String: UInt64] = [:]
        var itemsByYear: [Int: Int] = [:]
        var sizeByYear: [Int: UInt64] = [:]
        var largestItems: [MediaItem] = []
        var oldestItems: [MediaItem] = []
        var newestItems: [MediaItem] = []
    }
    
    @MainActor
    func analyzeMediaLibrary() async {
        logger.info("Starting media library analysis")
        analysisStatus = .analyzing
        
        let authorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch authorizationStatus {
        case .authorized, .limited:
            await performMediaAnalysis()
        case .denied, .restricted:
            analysisStatus = .permissionDenied
            logger.warning("Photo library access denied")
        case .notDetermined:
            let granted = await requestPhotoLibraryPermission()
            if granted {
                await performMediaAnalysis()
            } else {
                analysisStatus = .permissionDenied
            }
        @unknown default:
            analysisStatus = .permissionDenied
        }
    }
    
    @MainActor
    private func requestPhotoLibraryPermission() async -> Bool {
        logger.debug("Requesting photo library permission")
        
        return await withCheckedContinuation { continuation in
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                continuation.resume(returning: status == .authorized || status == .limited)
            }
        }
    }
    
    private func performMediaAnalysis() async {
        logger.debug("Performing media library analysis")
        
        await Task.detached(priority: .userInitiated) {
            await self.fetchMediaAssets()
            await self.categorizeMedia()
            await self.calculateStatistics()
        }.value
        
        await MainActor.run {
            self.lastAnalysisDate = Date()
            self.analysisStatus = .completed
        }
        logger.info("Media library analysis completed. Found \(self.mediaItems.count) items")
    }
    
    private func fetchMediaAssets() async {
        logger.debug("Fetching media assets")
        
        // In a real implementation, you would:
        // 1. Use PHAsset to fetch all media assets
        // 2. Get detailed information for each asset
        // 3. Handle large libraries efficiently
        
        // For now, we'll simulate media assets
        let simulatedAssets = await simulateMediaAssets()
        
        await MainActor.run {
            self.mediaItems = simulatedAssets
        }
    }
    
    private func categorizeMedia() async {
        logger.debug("Categorizing media items")
        
        let categories = [
            ("Photos", MediaItem.MediaType.photo),
            ("Videos", MediaItem.MediaType.video),
            ("Audio", MediaItem.MediaType.audio)
        ]
        
        var categorizedMedia: [MediaCategory] = []
        
        for (categoryName, mediaType) in categories {
            let categoryItems = mediaItems.filter { $0.mediaType == mediaType }
            let totalSize = categoryItems.reduce(0) { $0 + $1.fileSize }
            
            let category = MediaCategory(
                name: categoryName,
                mediaType: mediaType,
                totalSize: totalSize,
                itemCount: categoryItems.count,
                items: categoryItems
            )
            
            categorizedMedia.append(category)
        }
        
        await MainActor.run {
            self.mediaCategories = categorizedMedia.sorted { $0.totalSize > $1.totalSize }
        }
    }
    
    private func calculateStatistics() async {
        logger.debug("Calculating media statistics")
        var statistics = MediaStatistics()
        for item in mediaItems {
            statistics.totalItems += 1
            statistics.totalSize += item.fileSize
            statistics.itemsByType[item.mediaType, default: 0] += 1
            statistics.sizeByType[item.mediaType, default: 0] += item.fileSize
            statistics.itemsByFormat[item.format, default: 0] += 1
            statistics.sizeByFormat[item.format, default: 0] += item.fileSize
            if let creationDate = item.creationDate {
                let year = Calendar.current.component(.year, from: creationDate)
                statistics.itemsByYear[year, default: 0] += 1
                statistics.sizeByYear[year, default: 0] += item.fileSize
            }
        }
        // Get largest items
        statistics.largestItems = Array(mediaItems.sorted { (a: MediaItem, b: MediaItem) -> Bool in a.fileSize > b.fileSize }.prefix(10))
        // Get oldest items
        statistics.oldestItems = Array(mediaItems.compactMap { (item: MediaItem) -> (MediaItem, Date)? in
            guard let creationDate = item.creationDate else { return nil }
            return (item, creationDate)
        }.sorted { (a: (MediaItem, Date), b: (MediaItem, Date)) -> Bool in a.1 < b.1 }.prefix(10).map { $0.0 })
        // Get newest items
        statistics.newestItems = Array(mediaItems.compactMap { (item: MediaItem) -> (MediaItem, Date)? in
            guard let creationDate = item.creationDate else { return nil }
            return (item, creationDate)
        }.sorted { (a: (MediaItem, Date), b: (MediaItem, Date)) -> Bool in a.1 > b.1 }.prefix(10).map { $0.0 })
        await MainActor.run {
            self.mediaStatistics = statistics
        }
    }
    
    private func simulateMediaAssets() async -> [MediaItem] {
        let photoFormats = ["JPEG", "HEIC", "PNG", "GIF"]
        let videoFormats = ["MP4", "MOV", "AVI", "M4V"]
        let audioFormats = ["MP3", "AAC", "WAV", "M4A"]
        
        var assets: [MediaItem] = []
        let now = Date()
        
        // Generate photos
        for i in 0..<100 {
            let creationDate = now.addingTimeInterval(-TimeInterval.random(in: 0...365*24*3600))
            let asset = MediaItem(
                assetID: "photo_\(i)",
                fileName: "IMG_\(String(format: "%04d", i)).\(photoFormats.randomElement() ?? "JPEG")",
                fileSize: UInt64.random(in: 1024*1024...20*1024*1024), // 1MB to 20MB
                mediaType: .photo,
                format: photoFormats.randomElement() ?? "JPEG",
                creationDate: creationDate,
                modificationDate: creationDate.addingTimeInterval(TimeInterval.random(in: 0...3600)),
                lastAccessedDate: now.addingTimeInterval(-TimeInterval.random(in: 0...7*24*3600)),
                duration: nil,
                dimensions: CGSize(width: Double.random(in: 1000...4000), height: Double.random(in: 1000...4000)),
                location: nil,
                isFavorite: Bool.random(),
                isHidden: false
            )
            assets.append(asset)
        }
        
        // Generate videos
        for i in 0..<30 {
            let creationDate = now.addingTimeInterval(-TimeInterval.random(in: 0...365*24*3600))
            let asset = MediaItem(
                assetID: "video_\(i)",
                fileName: "VID_\(String(format: "%04d", i)).\(videoFormats.randomElement() ?? "MP4")",
                fileSize: UInt64.random(in: 10*1024*1024...500*1024*1024), // 10MB to 500MB
                mediaType: .video,
                format: videoFormats.randomElement() ?? "MP4",
                creationDate: creationDate,
                modificationDate: creationDate.addingTimeInterval(TimeInterval.random(in: 0...3600)),
                lastAccessedDate: now.addingTimeInterval(-TimeInterval.random(in: 0...7*24*3600)),
                duration: TimeInterval.random(in: 10...300), // 10 seconds to 5 minutes
                dimensions: CGSize(width: Double.random(in: 1280...3840), height: Double.random(in: 720...2160)),
                location: nil,
                isFavorite: Bool.random(),
                isHidden: false
            )
            assets.append(asset)
        }
        
        // Generate audio files
        for i in 0..<20 {
            let creationDate = now.addingTimeInterval(-TimeInterval.random(in: 0...365*24*3600))
            let asset = MediaItem(
                assetID: "audio_\(i)",
                fileName: "AUD_\(String(format: "%04d", i)).\(audioFormats.randomElement() ?? "MP3")",
                fileSize: UInt64.random(in: 1024*1024...50*1024*1024), // 1MB to 50MB
                mediaType: .audio,
                format: audioFormats.randomElement() ?? "MP3",
                creationDate: creationDate,
                modificationDate: creationDate.addingTimeInterval(TimeInterval.random(in: 0...3600)),
                lastAccessedDate: now.addingTimeInterval(-TimeInterval.random(in: 0...7*24*3600)),
                duration: TimeInterval.random(in: 60...3600), // 1 minute to 1 hour
                dimensions: nil,
                location: nil,
                isFavorite: Bool.random(),
                isHidden: false
            )
            assets.append(asset)
        }
        
        return assets.sorted { $0.creationDate ?? now > $1.creationDate ?? now }
    }
    
    func getMediaItemsByType(_ type: MediaItem.MediaType) -> [MediaItem] {
        return mediaItems.filter { $0.mediaType == type }
    }
    
    func getMediaItemsByFormat(_ format: String) -> [MediaItem] {
        return mediaItems.filter { $0.format == format }
    }
    
    func getMediaItemsByYear(_ year: Int) -> [MediaItem] {
        return mediaItems.filter { item in
            guard let creationDate = item.creationDate else { return false }
            return Calendar.current.component(.year, from: creationDate) == year
        }
    }
    
    func getLargeMediaItems(threshold: UInt64 = 100*1024*1024) -> [MediaItem] {
        return mediaItems.filter { $0.fileSize > threshold }
    }
    
    func getOldMediaItems(daysThreshold: Int = 365) -> [MediaItem] {
        let thresholdDate = Calendar.current.date(byAdding: .day, value: -daysThreshold, to: Date()) ?? Date()
        return mediaItems.filter { item in
            guard let creationDate = item.creationDate else { return false }
            return creationDate < thresholdDate
        }
    }
    
    func getFavoriteMediaItems() -> [MediaItem] {
        return mediaItems.filter { $0.isFavorite }
    }
    
    func getHiddenMediaItems() -> [MediaItem] {
        return mediaItems.filter { $0.isHidden }
    }
    
    func getAnalysisStatusDescription() -> String {
        switch analysisStatus {
        case .idle:
            return "Ready to analyze"
        case .analyzing:
            return "Analyzing media library..."
        case .completed:
            return "Analysis completed"
        case .error:
            return "Analysis failed"
        case .permissionDenied:
            return "Photo library access denied"
        }
    }
    
    func getAnalysisStatusColor() -> Color {
        switch analysisStatus {
        case .idle:
            return .gray
        case .analyzing:
            return .orange
        case .completed:
            return .green
        case .error:
            return .red
        case .permissionDenied:
            return .red
        }
    }
    
    static func formatBytes(_ bytes: UInt64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useGB, .useMB, .useKB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
    
    func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "Unknown" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    func getMediaTypeDescription(_ type: MediaItem.MediaType) -> String {
        switch type {
        case .photo:
            return "Photo"
        case .video:
            return "Video"
        case .audio:
            return "Audio"
        case .unknown:
            return "Unknown"
        }
    }
    
    func getMediaTypeIcon(_ type: MediaItem.MediaType) -> String {
        switch type {
        case .photo:
            return "photo"
        case .video:
            return "video"
        case .audio:
            return "music.note"
        case .unknown:
            return "questionmark"
        }
    }
    
    func getMediaTypeColor(_ type: MediaItem.MediaType) -> Color {
        switch type {
        case .photo:
            return .blue
        case .video:
            return .purple
        case .audio:
            return .green
        case .unknown:
            return .gray
        }
    }
    
    func clearAnalysisData() {
        logger.info("Clearing media analysis data")
        mediaItems.removeAll()
        mediaCategories.removeAll()
        mediaStatistics = MediaStatistics()
        analysisStatus = .idle
    }
} 