import SwiftUI

struct DetailedCPUView: View {
    let userUsage: Double
    let systemUsage: Double
    let idleUsage: Double

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 24) {
                    // CPU Pie Chart Section
                    VStack(alignment: .leading, spacing: 16) {
                        ModernSectionHeader(title: "CPU Usage Distribution", icon: "chart.pie")
                        
                        CPUPieChartView(user: userUsage, system: systemUsage, idle: idleUsage)
                            .frame(height: 250)
                            .modernCard(padding: 16)
                    }
                    
                    // CPU Info More Section
                    VStack(alignment: .leading, spacing: 16) {
                        ModernSectionHeader(title: "CPU Details", icon: "info.circle")
                        
                        CPUInfoMoreView()
                    }
                    .modernCard()
                    
                    // Definitions Section
                    VStack(alignment: .leading, spacing: 16) {
                        ModernSectionHeader(title: "Definitions", icon: "book")
                        
                        DefinitionsView()
                    }
                    .modernCard()
                }
                .padding()
            }
            .background(Color(UIColor.systemBackground).ignoresSafeArea())
            .navigationTitle("CPU Details")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
