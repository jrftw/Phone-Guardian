// DetailedMacView.swift

import SwiftUI

struct DetailedMacView: View {
    let macs: [Device] = [
        Device(
            name: "Mac mini (M1, 2020)",
            releaseDate: "November 17, 2020",
            specifications: [
                "Model Numbers": "A2348 (Macmini9,1)",
                "Processor": "Apple M1",
                "Memory": "8 GB or 16 GB",
                "Storage": "256 GB, 512 GB, or 1 TB SSD",
                "Operating System": "macOS 11.0, upgradable to latest",
                "Color": "Silver"
            ]
        ),
        Device(
            name: "iMac (24-inch, M1, 2021)",
            releaseDate: "May 21, 2021",
            specifications: [
                "Model Numbers": "A2438 (iMac21,1), A2439 (iMac21,2)",
                "Processor": "Apple M1",
                "Memory": "8 GB or 16 GB",
                "Storage": "256 GB, 512 GB, or 1 TB SSD",
                "Display": "24-inch Retina 4.5K display",
                "Operating System": "macOS 11.3, upgradable to latest",
                "Colors": "Silver, Pink, Blue, Green, Yellow, Orange, Purple"
            ]
        ),
        Device(
            name: "MacBook Air (M1, 2020)",
            releaseDate: "November 17, 2020",
            specifications: [
                "Model Numbers": "A2337 (MacBookAir10,1)",
                "Processor": "Apple M1",
                "Memory": "8 GB or 16 GB",
                "Storage": "256 GB, 512 GB, or 1 TB SSD",
                "Display": "13.3-inch Retina display",
                "Operating System": "macOS 11.0, upgradable to latest",
                "Colors": "Space Gray, Silver, Gold"
            ]
        ),
        Device(
            name: "MacBook Pro (13-inch, M1, 2020)",
            releaseDate: "November 17, 2020",
            specifications: [
                "Model Numbers": "A2338 (MacBookPro17,1)",
                "Processor": "Apple M1",
                "Memory": "8 GB or 16 GB",
                "Storage": "256 GB, 512 GB, or 1 TB SSD",
                "Display": "13.3-inch Retina display",
                "Operating System": "macOS 11.0, upgradable to latest",
                "Colors": "Space Gray, Silver"
            ]
        ),
        Device(
            name: "MacBook Pro (14-inch, 2021)",
            releaseDate: "October 26, 2021",
            specifications: [
                "Model Numbers": "A2442 (MacBookPro18,3 and MacBookPro18,4)",
                "Processor": "Apple M1 Pro or M1 Max",
                "Memory": "16 GB, 32 GB, or 64 GB",
                "Storage": "512 GB, 1 TB, 2 TB, 4 TB, or 8 TB SSD",
                "Display": "14.2-inch Liquid Retina XDR display",
                "Operating System": "macOS 12.0, upgradable to latest",
                "Colors": "Space Gray, Silver"
            ]
        ),
        Device(
            name: "MacBook Pro (16-inch, 2021)",
            releaseDate: "October 26, 2021",
            specifications: [
                "Model Numbers": "A2485 (MacBookPro18,1 and MacBookPro18,2)",
                "Processor": "Apple M1 Pro or M1 Max",
                "Memory": "16 GB, 32 GB, or 64 GB",
                "Storage": "512 GB, 1 TB, 2 TB, 4 TB, or 8 TB SSD",
                "Display": "16.2-inch Liquid Retina XDR display",
                "Operating System": "macOS 12.0, upgradable to latest",
                "Colors": "Space Gray, Silver"
            ]
        ),
        Device(
            name: "Mac Studio (M1 Max, 2022)",
            releaseDate: "March 18, 2022",
            specifications: [
                "Model Numbers": "A2615 (Mac13,1)",
                "Processor": "Apple M1 Max",
                "Memory": "32 GB or 64 GB",
                "Storage": "512 GB, 1 TB, 2 TB, 4 TB, or 8 TB SSD",
                "Operating System": "macOS 12.3, upgradable to latest",
                "Color": "Silver"
            ]
        ),
        Device(
            name: "Mac Studio (M1 Ultra, 2022)",
            releaseDate: "March 18, 2022",
            specifications: [
                "Model Numbers": "A2615 (Mac13,2)",
                "Processor": "Apple M1 Ultra",
                "Memory": "64 GB or 128 GB",
                "Storage": "1 TB, 2 TB, 4 TB, or 8 TB SSD",
                "Operating System": "macOS 12.3, upgradable to latest",
                "Color": "Silver"
            ]
        ),
    ]

    var body: some View {
        NavigationView {
            List(macs) { mac in
                NavigationLink(destination: DeviceDetailView(device: mac)) {
                    Text(mac.name)
                        .font(.headline)
                }
            }
            .navigationTitle("Supported Macs")
        }
    }
}
