import SwiftUI
import UniformTypeIdentifiers

struct DetectionLogView: View {
    @ObservedObject var vpnManager: VPNManager
    @State private var detections: [LocationDetection] = []
    @State private var searchText = ""
    @State private var selectedFilter: FilterOption = .all
    @State private var showingExportSheet = false
    @State private var showingClearAlert = false
    
    enum FilterOption: String, CaseIterable {
        case all = "All"
        case today = "Today"
        case thisWeek = "This Week"
        case thisMonth = "This Month"
        
        var displayName: String {
            return self.rawValue
        }
    }
    
    var filteredDetections: [LocationDetection] {
        var filtered = detections
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { detection in
                detection.service.localizedCaseInsensitiveContains(searchText) ||
                detection.domain.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply time filter
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedFilter {
        case .today:
            filtered = filtered.filter { calendar.isDate($0.timestamp, inSameDayAs: now) }
        case .thisWeek:
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
            filtered = filtered.filter { $0.timestamp >= weekAgo }
        case .thisMonth:
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            filtered = filtered.filter { $0.timestamp >= monthAgo }
        case .all:
            break
        }
        
        return filtered.sorted { $0.timestamp > $1.timestamp }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and Filter Bar
                searchAndFilterBar
                
                // Detection List
                if filteredDetections.isEmpty {
                    emptyStateView
                } else {
                    detectionList
                }
            }
            .navigationTitle("Detection History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        // Dismiss view
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: exportDetections) {
                            Label("Export as JSON", systemImage: "square.and.arrow.up")
                        }
                        
                        Button(action: exportDetectionsAsText) {
                            Label("Export as Text", systemImage: "doc.text")
                        }
                        
                        Divider()
                        
                        Button(role: .destructive, action: { showingClearAlert = true }) {
                            Label("Clear All", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .onAppear {
                loadDetections()
            }
            .alert("Clear Detection History", isPresented: $showingClearAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear All", role: .destructive) {
                    clearAllDetections()
                }
            } message: {
                Text("This will permanently delete all detection records. This action cannot be undone.")
            }
        }
    }
    
    // MARK: - Search and Filter Bar
    private var searchAndFilterBar: some View {
        VStack(spacing: 12) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search detections...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.ultraThinMaterial)
            )
            
            // Filter Picker
            Picker("Filter", selection: $selectedFilter) {
                ForEach(FilterOption.allCases, id: \.self) { option in
                    Text(option.displayName).tag(option)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
        .padding(.horizontal)
        .padding(.top)
    }
    
    // MARK: - Detection List
    private var detectionList: some View {
        List {
            ForEach(groupedDetections, id: \.date) { group in
                Section(header: Text(group.date)) {
                    ForEach(group.detections) { detection in
                        DetectionDetailRow(detection: detection)
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.shield")
                .font(.system(size: 64))
                .foregroundColor(.green)
            
            Text("No Detections Found")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("No location access attempts have been detected yet.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if !searchText.isEmpty || selectedFilter != .all {
                Button("Clear Filters") {
                    searchText = ""
                    selectedFilter = .all
                }
                .foregroundColor(.accentColor)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Grouped Detections
    private var groupedDetections: [DetectionGroup] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredDetections) { detection in
            calendar.startOfDay(for: detection.timestamp)
        }
        
        return grouped.map { date, detections in
            DetectionGroup(date: formatDate(date), detections: detections)
        }.sorted { $0.date > $1.date }
    }
    
    // MARK: - Helper Methods
    private func loadDetections() {
        detections = vpnManager.loadDetections()
        // Also load detections from tunnel extension
        let tunnelDetections = vpnManager.loadTunnelDetections()
        detections.append(contentsOf: tunnelDetections)
        
        // Remove duplicates and sort by timestamp
        let uniqueDetections = Array(Set(detections.map { "\($0.timestamp.timeIntervalSince1970)-\($0.domain)" }))
            .compactMap { key in
                detections.first { "\($0.timestamp.timeIntervalSince1970)-\($0.domain)" == key }
            }
        
        detections = uniqueDetections.sorted { $0.timestamp > $1.timestamp }
    }
    
    private func clearAllDetections() {
        vpnManager.clearDetections()
        loadDetections()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func exportDetections() {
        let exportData = ExportData(
            exportDate: Date(),
            totalDetections: detections.count,
            detections: detections
        )
        
        if let jsonData = try? JSONEncoder().encode(exportData),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            let activityVC = UIActivityViewController(
                activityItems: [jsonString],
                applicationActivities: nil
            )
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController?.present(activityVC, animated: true)
            }
        }
    }
    
    private func exportDetectionsAsText() {
        let textContent = createTextExport()
        let activityVC = UIActivityViewController(
            activityItems: [textContent],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
    
    private func createTextExport() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        
        var text = "INFILOC Detection History\n"
        text += "Exported: \(formatter.string(from: Date()))\n"
        text += "Total Detections: \(detections.count)\n\n"
        
        for detection in detections.sorted(by: { $0.timestamp > $1.timestamp }) {
            text += "[\(formatter.string(from: detection.timestamp))] "
            text += "\(detection.service) - \(detection.domain)\n"
        }
        
        return text
    }
}

// MARK: - Supporting Models
struct DetectionGroup {
    let date: String
    let detections: [LocationDetection]
}

struct ExportData: Codable {
    let exportDate: Date
    let totalDetections: Int
    let detections: [LocationDetection]
}

// MARK: - Detection Detail Row
struct DetectionDetailRow: View {
    let detection: LocationDetection
    @State private var showingDetails = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "location.circle.fill")
                    .foregroundColor(.red)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(detection.service)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(detection.domain)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(detection.formattedTime)
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    Text(detection.formattedDate)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            if showingDetails {
                VStack(alignment: .leading, spacing: 8) {
                    Divider()
                    
                    HStack {
                        Text("Domain:")
                            .font(.caption)
                            .fontWeight(.medium)
                        Spacer()
                        Text(detection.domain)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Service:")
                            .font(.caption)
                            .fontWeight(.medium)
                        Spacer()
                        Text(detection.service)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Timestamp:")
                            .font(.caption)
                            .fontWeight(.medium)
                        Spacer()
                        Text(detection.timestamp, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                showingDetails.toggle()
            }
        }
    }
} 