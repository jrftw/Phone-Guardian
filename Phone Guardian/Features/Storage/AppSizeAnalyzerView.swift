import SwiftUI

struct AppSizeAnalyzerView: View {
    @StateObject private var analyzer = AppSizeAnalyzerManager.shared
    @State private var isAnalyzing = false
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                // Summary Section
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "App Size Summary", icon: "apps.iphone")
                    
                    LazyVStack(spacing: 8) {
                        ModernInfoRow(icon: "apps.iphone", label: "Total App Size", value: AppSizeAnalyzerManager.formatBytes(analyzer.totalAppSize), iconColor: .blue)
                        ModernInfoRow(icon: "number", label: "Total Apps", value: "\(analyzer.installedApps.count)", iconColor: .green)
                        ModernInfoRow(icon: "clock", label: "Last Analysis", value: analyzer.formatDate(analyzer.lastAnalysisDate), iconColor: .orange)
                        ModernInfoRow(icon: "checkmark.circle", label: "Status", value: analyzer.getAnalysisStatusDescription(), iconColor: analyzer.getAnalysisStatusColor())
                    }
                }
                .modernCard()
                
                // Largest Apps Section
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "Largest Apps", icon: "arrow.up.right.square")
                    
                    if analyzer.installedApps.isEmpty {
                        Text("No app data available. Run analysis to see results.")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        LazyVStack(spacing: 8) {
                            ForEach(analyzer.getLargestApps(limit: 10)) { app in
                                AppInfoRow(app: app)
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
                            await analyzer.analyzeInstalledApps()
                            isAnalyzing = false
                        }
                    }) {
                        HStack {
                            Image(systemName: isAnalyzing ? "hourglass" : "magnifyingglass")
                            Text(isAnalyzing ? "Analyzing..." : "Analyze Installed Apps")
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
        .navigationTitle("App Size Analyzer")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if analyzer.installedApps.isEmpty {
                Task { await analyzer.analyzeInstalledApps() }
            }
        }
    }
}

struct AppInfoRow: View {
    let app: AppSizeAnalyzerManager.AppInfo
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "app")
                .foregroundColor(.accentColor)
                .font(.title3)
            VStack(alignment: .leading, spacing: 2) {
                Text(app.displayName)
                    .font(.headline)
                Text(app.version)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(app.formattedTotalSize)
                .font(.subheadline)
                .foregroundColor(.blue)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial)
        )
    }
} 