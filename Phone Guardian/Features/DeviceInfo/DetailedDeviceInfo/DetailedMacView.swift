// DetailedMacView.swift

import SwiftUI

struct DetailedMacView: View {
    let macs: [Device] = [
        // Older Intel Macs (2018-2020)
        Device(
            name: "MacBook Air (13-inch, 2018)",
            releaseDate: "October 30, 2018",
            specifications: [
                "Model Numbers": "A1932 (MacBookAir8,1)",
                "Processor": "Intel Core i5-8210Y",
                "Memory": "8 GB or 16 GB",
                "Storage": "128 GB, 256 GB, 512 GB, or 1.5 TB SSD",
                "Display": "13.3-inch Retina display",
                "Operating System": "macOS 10.14, upgradable to latest",
                "Colors": "Space Gray, Silver, Gold"
            ]
        ),
        Device(
            name: "MacBook Air (13-inch, 2019)",
            releaseDate: "July 9, 2019",
            specifications: [
                "Model Numbers": "A1932 (MacBookAir8,2)",
                "Processor": "Intel Core i5-8210Y",
                "Memory": "8 GB or 16 GB",
                "Storage": "128 GB, 256 GB, 512 GB, or 1.5 TB SSD",
                "Display": "13.3-inch Retina display",
                "Operating System": "macOS 10.14.5, upgradable to latest",
                "Colors": "Space Gray, Silver, Gold"
            ]
        ),
        Device(
            name: "MacBook Air (13-inch, 2020)",
            releaseDate: "March 18, 2020",
            specifications: [
                "Model Numbers": "A2179 (MacBookAir9,1)",
                "Processor": "Intel Core i3-1000NG4 or i5-1030NG7",
                "Memory": "8 GB or 16 GB",
                "Storage": "256 GB, 512 GB, 1 TB, or 2 TB SSD",
                "Display": "13.3-inch Retina display",
                "Operating System": "macOS 10.15.3, upgradable to latest",
                "Colors": "Space Gray, Silver, Gold"
            ]
        ),
        Device(
            name: "MacBook Pro (13-inch, 2018)",
            releaseDate: "July 12, 2018",
            specifications: [
                "Model Numbers": "A1989 (MacBookPro15,2)",
                "Processor": "Intel Core i5-8259U or i7-8559U",
                "Memory": "8 GB or 16 GB",
                "Storage": "256 GB, 512 GB, 1 TB, or 2 TB SSD",
                "Display": "13.3-inch Retina display",
                "Operating System": "macOS 10.14, upgradable to latest",
                "Colors": "Space Gray, Silver"
            ]
        ),
        Device(
            name: "MacBook Pro (15-inch, 2018)",
            releaseDate: "July 12, 2018",
            specifications: [
                "Model Numbers": "A1990 (MacBookPro15,1)",
                "Processor": "Intel Core i7-8750H or i9-8950HK",
                "Memory": "16 GB, 32 GB, or 64 GB",
                "Storage": "256 GB, 512 GB, 1 TB, 2 TB, or 4 TB SSD",
                "Display": "15.4-inch Retina display",
                "Operating System": "macOS 10.14, upgradable to latest",
                "Colors": "Space Gray, Silver"
            ]
        ),
        Device(
            name: "MacBook Pro (16-inch, 2019)",
            releaseDate: "November 13, 2019",
            specifications: [
                "Model Numbers": "A2141 (MacBookPro16,1)",
                "Processor": "Intel Core i7-9750H or i9-9880H",
                "Memory": "16 GB, 32 GB, or 64 GB",
                "Storage": "512 GB, 1 TB, 2 TB, 4 TB, or 8 TB SSD",
                "Display": "16-inch Retina display",
                "Operating System": "macOS 10.15.1, upgradable to latest",
                "Colors": "Space Gray, Silver"
            ]
        ),
        Device(
            name: "iMac (21.5-inch, 2019)",
            releaseDate: "March 19, 2019",
            specifications: [
                "Model Numbers": "A2115 (iMac19,2)",
                "Processor": "Intel Core i3-8100 or i5-8500",
                "Memory": "8 GB or 16 GB",
                "Storage": "1 TB Fusion Drive or 256 GB, 512 GB, or 1 TB SSD",
                "Display": "21.5-inch Retina 4K display",
                "Operating System": "macOS 10.14.5, upgradable to latest",
                "Colors": "Silver"
            ]
        ),
        Device(
            name: "iMac (27-inch, 2019)",
            releaseDate: "March 19, 2019",
            specifications: [
                "Model Numbers": "A2116 (iMac19,1)",
                "Processor": "Intel Core i5-8500 or i5-9600K",
                "Memory": "8 GB, 16 GB, 32 GB, or 64 GB",
                "Storage": "1 TB Fusion Drive or 256 GB, 512 GB, 1 TB, or 2 TB SSD",
                "Display": "27-inch Retina 5K display",
                "Operating System": "macOS 10.14.5, upgradable to latest",
                "Colors": "Silver"
            ]
        ),
        Device(
            name: "Mac mini (2018)",
            releaseDate: "October 30, 2018",
            specifications: [
                "Model Numbers": "A1993 (Macmini8,1)",
                "Processor": "Intel Core i3-8100B or i5-8500B",
                "Memory": "8 GB or 16 GB",
                "Storage": "128 GB, 256 GB, 512 GB, 1 TB, or 2 TB SSD",
                "Operating System": "macOS 10.14, upgradable to latest",
                "Color": "Silver"
            ]
        ),
        Device(
            name: "Mac Pro (2019)",
            releaseDate: "December 10, 2019",
            specifications: [
                "Model Numbers": "A1991 (MacPro7,1)",
                "Processor": "Intel Xeon W-3223, W-3235, W-3245, W-3265, W-3275, or W-3285",
                "Memory": "32 GB, 48 GB, 96 GB, 192 GB, 384 GB, 768 GB, or 1.5 TB",
                "Storage": "256 GB, 1 TB, 2 TB, or 4 TB SSD",
                "Operating System": "macOS 10.15.1, upgradable to latest",
                "Color": "Space Gray"
            ]
        ),
        
        // Apple Silicon Macs (M1 Series - 2020-2022)
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
            name: "Mac mini (M1, 2020)",
            releaseDate: "November 17, 2020",
            specifications: [
                "Model Numbers": "A2348 (Mac14,6)",
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
                "Model Numbers": "A2438 (Mac14,2), A2439 (Mac14,3), A2440 (Mac14,4), A2441 (Mac14,5)",
                "Processor": "Apple M1",
                "Memory": "8 GB or 16 GB",
                "Storage": "256 GB, 512 GB, or 1 TB SSD",
                "Display": "24-inch Retina 4.5K display",
                "Operating System": "macOS 11.3, upgradable to latest",
                "Colors": "Silver, Pink, Blue, Green, Yellow, Orange, Purple"
            ]
        ),
        Device(
            name: "MacBook Pro (14-inch, M1 Pro/Max, 2021)",
            releaseDate: "October 26, 2021",
            specifications: [
                "Model Numbers": "A2442 (MacBookPro18,3), A2442 (MacBookPro18,4)",
                "Processor": "Apple M1 Pro or M1 Max",
                "Memory": "16 GB, 32 GB, or 64 GB",
                "Storage": "512 GB, 1 TB, 2 TB, 4 TB, or 8 TB SSD",
                "Display": "14.2-inch Liquid Retina XDR display",
                "Operating System": "macOS 12.0, upgradable to latest",
                "Colors": "Space Gray, Silver"
            ]
        ),
        Device(
            name: "MacBook Pro (16-inch, M1 Pro/Max, 2021)",
            releaseDate: "October 26, 2021",
            specifications: [
                "Model Numbers": "A2485 (MacBookPro18,1), A2485 (MacBookPro18,2)",
                "Processor": "Apple M1 Pro or M1 Max",
                "Memory": "16 GB, 32 GB, or 64 GB",
                "Storage": "512 GB, 1 TB, 2 TB, 4 TB, or 8 TB SSD",
                "Display": "16.2-inch Liquid Retina XDR display",
                "Operating System": "macOS 12.0, upgradable to latest",
                "Colors": "Space Gray, Silver"
            ]
        ),
        Device(
            name: "Mac Studio (M1 Max/Ultra, 2022)",
            releaseDate: "March 18, 2022",
            specifications: [
                "Model Numbers": "A2615 (Mac14,7), A2615 (Mac14,8), A2615 (Mac14,9), A2615 (Mac14,10), A2615 (Mac14,11), A2615 (Mac14,12)",
                "Processor": "Apple M1 Max or M1 Ultra",
                "Memory": "32 GB, 64 GB, or 128 GB",
                "Storage": "512 GB, 1 TB, 2 TB, 4 TB, or 8 TB SSD",
                "Operating System": "macOS 12.3, upgradable to latest",
                "Color": "Silver"
            ]
        ),
        
        // Apple Silicon Macs (M2 Series - 2022-2023)
        Device(
            name: "MacBook Air (M2, 2022)",
            releaseDate: "July 15, 2022",
            specifications: [
                "Model Numbers": "A2681 (MacBookAir10,2)",
                "Processor": "Apple M2",
                "Memory": "8 GB or 16 GB",
                "Storage": "256 GB, 512 GB, 1 TB, or 2 TB SSD",
                "Display": "13.6-inch Liquid Retina display",
                "Operating System": "macOS 12.0, upgradable to latest",
                "Colors": "Space Gray, Silver, Starlight, Midnight"
            ]
        ),
        Device(
            name: "MacBook Air (15-inch, M2, 2023)",
            releaseDate: "June 13, 2023",
            specifications: [
                "Model Numbers": "A2941 (MacBookAir10,3)",
                "Processor": "Apple M2",
                "Memory": "8 GB or 16 GB",
                "Storage": "256 GB, 512 GB, 1 TB, or 2 TB SSD",
                "Display": "15.3-inch Liquid Retina display",
                "Operating System": "macOS 13.0, upgradable to latest",
                "Colors": "Space Gray, Silver, Starlight, Midnight"
            ]
        ),
        Device(
            name: "MacBook Pro (13-inch, M2, 2022)",
            releaseDate: "June 24, 2022",
            specifications: [
                "Model Numbers": "A2338 (MacBookPro18,5)",
                "Processor": "Apple M2",
                "Memory": "8 GB or 16 GB",
                "Storage": "256 GB, 512 GB, 1 TB, or 2 TB SSD",
                "Display": "13.3-inch Retina display",
                "Operating System": "macOS 13.0, upgradable to latest",
                "Colors": "Space Gray, Silver"
            ]
        ),
        Device(
            name: "MacBook Pro (14-inch, M2 Pro/Max, 2023)",
            releaseDate: "January 24, 2023",
            specifications: [
                "Model Numbers": "A2779 (MacBookPro18,7)",
                "Processor": "Apple M2 Pro or M2 Max",
                "Memory": "16 GB, 32 GB, 64 GB, or 96 GB",
                "Storage": "512 GB, 1 TB, 2 TB, 4 TB, or 8 TB SSD",
                "Display": "14.2-inch Liquid Retina XDR display",
                "Operating System": "macOS 13.0, upgradable to latest",
                "Colors": "Space Gray, Silver"
            ]
        ),
        Device(
            name: "MacBook Pro (16-inch, M2 Pro/Max, 2023)",
            releaseDate: "January 24, 2023",
            specifications: [
                "Model Numbers": "A2781 (MacBookPro18,6)",
                "Processor": "Apple M2 Pro or M2 Max",
                "Memory": "16 GB, 32 GB, 64 GB, or 96 GB",
                "Storage": "512 GB, 1 TB, 2 TB, 4 TB, or 8 TB SSD",
                "Display": "16.2-inch Liquid Retina XDR display",
                "Operating System": "macOS 13.0, upgradable to latest",
                "Colors": "Space Gray, Silver"
            ]
        ),
        Device(
            name: "Mac mini (M2, 2023)",
            releaseDate: "January 24, 2023",
            specifications: [
                "Model Numbers": "A2781 (Mac14,15)",
                "Processor": "Apple M2",
                "Memory": "8 GB or 16 GB",
                "Storage": "256 GB, 512 GB, 1 TB, or 2 TB SSD",
                "Operating System": "macOS 13.0, upgradable to latest",
                "Color": "Silver"
            ]
        ),
        Device(
            name: "Mac mini (M2 Pro, 2023)",
            releaseDate: "January 24, 2023",
            specifications: [
                "Model Numbers": "A2781 (Mac14,16)",
                "Processor": "Apple M2 Pro",
                "Memory": "16 GB or 32 GB",
                "Storage": "512 GB, 1 TB, 2 TB, 4 TB, or 8 TB SSD",
                "Operating System": "macOS 13.0, upgradable to latest",
                "Color": "Silver"
            ]
        ),
        Device(
            name: "Mac Studio (M2 Max/Ultra, 2023)",
            releaseDate: "June 13, 2023",
            specifications: [
                "Model Numbers": "A2855 (Mac14,17), A2855 (Mac14,18), A2855 (Mac14,19), A2855 (Mac14,20), A2855 (Mac14,21), A2855 (Mac14,22), A2855 (Mac14,23), A2855 (Mac14,24)",
                "Processor": "Apple M2 Max or M2 Ultra",
                "Memory": "32 GB, 64 GB, 96 GB, or 192 GB",
                "Storage": "512 GB, 1 TB, 2 TB, 4 TB, or 8 TB SSD",
                "Operating System": "macOS 13.2, upgradable to latest",
                "Color": "Silver"
            ]
        ),
        
        // Apple Silicon Macs (M3 Series - 2024-2025)
        Device(
            name: "MacBook Air (M3, 2024)",
            releaseDate: "March 4, 2024",
            specifications: [
                "Model Numbers": "A2941 (MacBookAir15,1), A2941 (MacBookAir15,2)",
                "Processor": "Apple M3",
                "Memory": "8 GB or 16 GB",
                "Storage": "256 GB, 512 GB, 1 TB, or 2 TB SSD",
                "Display": "13.6-inch Liquid Retina display",
                "Operating System": "macOS 14.1, upgradable to latest",
                "Colors": "Space Gray, Silver, Starlight, Midnight"
            ]
        ),
        Device(
            name: "MacBook Pro (14-inch, M3 Pro/Max, 2024)",
            releaseDate: "October 30, 2024",
            specifications: [
                "Model Numbers": "A2992 (MacBookPro18,8), A2992 (MacBookPro18,9)",
                "Processor": "Apple M3 Pro or M3 Max",
                "Memory": "18 GB, 36 GB, 64 GB, 96 GB, or 128 GB",
                "Storage": "512 GB, 1 TB, 2 TB, 4 TB, or 8 TB SSD",
                "Display": "14.2-inch Liquid Retina XDR display",
                "Operating System": "macOS 14.1, upgradable to latest",
                "Colors": "Space Gray, Silver"
            ]
        ),
        Device(
            name: "MacBook Pro (16-inch, M3 Pro/Max, 2024)",
            releaseDate: "October 30, 2024",
            specifications: [
                "Model Numbers": "A2991 (MacBookPro18,10), A2991 (MacBookPro18,11)",
                "Processor": "Apple M3 Pro or M3 Max",
                "Memory": "18 GB, 36 GB, 64 GB, 96 GB, or 128 GB",
                "Storage": "512 GB, 1 TB, 2 TB, 4 TB, or 8 TB SSD",
                "Display": "16.2-inch Liquid Retina XDR display",
                "Operating System": "macOS 14.1, upgradable to latest",
                "Colors": "Space Gray, Silver"
            ]
        ),
        Device(
            name: "iMac (M3, 2024)",
            releaseDate: "October 30, 2024",
            specifications: [
                "Model Numbers": "A2993 (Mac15,1), A2993 (Mac15,2), A2993 (Mac15,3), A2993 (Mac15,4)",
                "Processor": "Apple M3",
                "Memory": "8 GB or 16 GB",
                "Storage": "256 GB, 512 GB, or 1 TB SSD",
                "Display": "24-inch Retina 4.5K display",
                "Operating System": "macOS 14.1, upgradable to latest",
                "Colors": "Silver, Pink, Blue, Green, Yellow, Orange, Purple"
            ]
        ),
        Device(
            name: "Mac mini (M3, 2024)",
            releaseDate: "October 30, 2024",
            specifications: [
                "Model Numbers": "A2994 (Mac15,5)",
                "Processor": "Apple M3",
                "Memory": "8 GB or 16 GB",
                "Storage": "256 GB, 512 GB, 1 TB, or 2 TB SSD",
                "Operating System": "macOS 14.1, upgradable to latest",
                "Color": "Silver"
            ]
        ),
        Device(
            name: "Mac mini (M3 Pro, 2024)",
            releaseDate: "October 30, 2024",
            specifications: [
                "Model Numbers": "A2994 (Mac15,6)",
                "Processor": "Apple M3 Pro",
                "Memory": "18 GB or 36 GB",
                "Storage": "512 GB, 1 TB, 2 TB, 4 TB, or 8 TB SSD",
                "Operating System": "macOS 14.1, upgradable to latest",
                "Color": "Silver"
            ]
        ),
        Device(
            name: "Mac Studio (M3 Max/Ultra, 2024)",
            releaseDate: "October 30, 2024",
            specifications: [
                "Model Numbers": "A2995 (Mac15,7), A2995 (Mac15,8), A2995 (Mac15,9), A2995 (Mac15,10), A2995 (Mac15,11), A2995 (Mac15,12), A2995 (Mac15,13), A2995 (Mac15,14)",
                "Processor": "Apple M3 Max or M3 Ultra",
                "Memory": "36 GB, 64 GB, 96 GB, 128 GB, or 192 GB",
                "Storage": "512 GB, 1 TB, 2 TB, 4 TB, or 8 TB SSD",
                "Operating System": "macOS 14.1, upgradable to latest",
                "Color": "Silver"
            ]
        )
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
