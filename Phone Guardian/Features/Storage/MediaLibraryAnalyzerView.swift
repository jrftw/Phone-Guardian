import SwiftUI

struct MediaLibraryAnalyzerView: View {
    @StateObject private var analyzer = MediaLibraryAnalyzerManager.shared
    @State private var isAnalyzing = false
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                // Summary Section
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "Media Library Summary", icon: "photo.on.rectangle")
                    
                    LazyVStack(spacing: 8) {
                        ModernInfoRow(icon: "photo.on.rectangle", label: "Total Media Size", value: MediaLibraryAnalyzerManager.formatBytes(analyzer.mediaStatistics.totalSize), iconColor: .blue)
                        ModernInfoRow(icon: "number", label: "Total Items", value: "\(analyzer.mediaStatistics.totalItems)", iconColor: .green)
                        ModernInfoRow(icon: "clock", label: "Last Analysis", value: analyzer.formatDate(analyzer.lastAnalysisDate), iconColor: .orange)
                        ModernInfoRow(icon: "checkmark.circle", label: "Status", value: analyzer.getAnalysisStatusDescription(), iconColor: analyzer.getAnalysisStatusColor())
                    }
                }
                .modernCard()
                
                // Largest Media Items Section
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "Largest Media Items", icon: "arrow.up.right.square")
                    
                    if analyzer.mediaStatistics.largestItems.isEmpty {
                        Text("No media data available. Run analysis to see results.")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        LazyVStack(spacing: 8) {
                            ForEach(analyzer.mediaStatistics.largestItems.prefix(10), id: \.id) { item in
                                MediaItemRow(item: item)
                            }
                        }
                    }
                }
                .modernCard()
                
                // Action Button
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "Actions", icon: "wrench.and.screwdriver")
                    Button(action: {
                        Task {
                            isAnalyzing = true
                            await analyzer.analyzeMediaLibrary()
                            isAnalyzing = false
                        }
                    }) {
                        HStack {
                            Image(systemName: isAnalyzing ? "hourglass" : "magnifyingglass")
                            Text(isAnalyzing ? "Analyzing..." : "Analyze Media Library")
                        }
                    }
                    .modernButton(backgroundColor: isAnalyzing ? .orange : .blue)
                    .disabled(isAnalyzing)
                }
                .modernCard()
            }
            .padding()
        }
        .background(Color(UIColor.systemBackground).ignoresSafeArea())
        .navigationTitle("Media Library Analyzer")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if analyzer.mediaStatistics.totalItems == 0 {
                Task { await analyzer.analyzeMediaLibrary() }
            }
        }
    }
}

struct MediaItemRow: View {
    let item: MediaLibraryAnalyzerManager.MediaItem
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
            VStack(alignment: .leading, spacing: 2) {
                Text(item.fileName)
                    .font(.headline)
                Text(item.formattedFileSize)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(typeText)
                .font(.subheadline)
                .foregroundColor(color)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial)
        )
    }
    
    private var icon: String {
        switch item.mediaType {
        case .photo: return "photo"
        case .video: return "video"
        case .audio: return "music.note"
        case .unknown: return "questionmark"
        }
    }
    private var color: Color {
        switch item.mediaType {
        case .photo: return .blue
        case .video: return .purple
        case .audio: return .green
        case .unknown: return .gray
        }
    }
    private var typeText: String {
        switch item.mediaType {
        case .photo: return "Photo"
        case .video: return "Video"
        case .audio: return "Audio"
        case .unknown: return "Unknown"
        }
    }
} 