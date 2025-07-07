// DetailediPadView.swift

import SwiftUI

struct DetailediPadView: View {
    let iPads: [Device] = [
        // Older iPads (2018-2020)
        Device(
            name: "iPad (6th generation)",
            releaseDate: "March 27, 2018",
            specifications: [
                "Model Numbers": "A1893 (iPad6,11), A1954 (iPad6,12)",
                "Processor": "A10 Fusion",
                "Memory": "2 GB",
                "Storage": "32 GB, 128 GB",
                "Display": "9.7-inch Retina display",
                "Operating System": "iOS 11.3, upgradable to latest",
                "Colors": "Space Gray, Silver, Gold"
            ]
        ),
        Device(
            name: "iPad Pro (11-inch) (1st generation)",
            releaseDate: "November 7, 2018",
            specifications: [
                "Model Numbers": "A1980 (iPad8,1), A2013 (iPad8,2), A1934 (iPad8,3), A1979 (iPad8,4)",
                "Processor": "A12X Bionic",
                "Memory": "4 GB or 6 GB",
                "Storage": "64 GB, 256 GB, 512 GB, 1 TB",
                "Display": "11-inch Liquid Retina display",
                "Operating System": "iOS 12.1, upgradable to latest",
                "Colors": "Space Gray, Silver"
            ]
        ),
        Device(
            name: "iPad Pro (12.9-inch) (4th generation)",
            releaseDate: "November 7, 2018",
            specifications: [
                "Model Numbers": "A1876 (iPad8,5), A2014 (iPad8,6), A1895 (iPad8,7), A1983 (iPad8,8)",
                "Processor": "A12X Bionic",
                "Memory": "4 GB or 6 GB",
                "Storage": "64 GB, 256 GB, 512 GB, 1 TB",
                "Display": "12.9-inch Liquid Retina display",
                "Operating System": "iOS 12.1, upgradable to latest",
                "Colors": "Space Gray, Silver"
            ]
        ),
        Device(
            name: "iPad (7th generation)",
            releaseDate: "September 25, 2019",
            specifications: [
                "Model Numbers": "A2197 (iPad7,11), A2200 (iPad7,12)",
                "Processor": "A10 Fusion",
                "Memory": "3 GB",
                "Storage": "32 GB, 128 GB",
                "Display": "10.2-inch Retina display",
                "Operating System": "iPadOS 13, upgradable to latest",
                "Colors": "Space Gray, Silver, Gold"
            ]
        ),
        Device(
            name: "iPad Air (3rd generation)",
            releaseDate: "March 18, 2019",
            specifications: [
                "Model Numbers": "A2152 (iPad11,3), A2123, A2153, A2154 (iPad11,4)",
                "Processor": "A12 Bionic",
                "Memory": "3 GB",
                "Storage": "64 GB, 256 GB",
                "Display": "10.5-inch Retina display",
                "Operating System": "iPadOS 13, upgradable to latest",
                "Colors": "Space Gray, Silver, Gold"
            ]
        ),
        Device(
            name: "iPad mini (5th generation)",
            releaseDate: "March 18, 2019",
            specifications: [
                "Model Numbers": "A2133 (iPad11,1), A2124, A2125, A2126 (iPad11,2)",
                "Processor": "A12 Bionic",
                "Memory": "3 GB",
                "Storage": "64 GB, 256 GB",
                "Display": "7.9-inch Retina display",
                "Operating System": "iPadOS 13, upgradable to latest",
                "Colors": "Space Gray, Silver, Gold"
            ]
        ),
        Device(
            name: "iPad Pro (11-inch) (2nd generation)",
            releaseDate: "March 25, 2020",
            specifications: [
                "Model Numbers": "A2228 (iPad8,9), A2068, A2230, A2231 (iPad8,10)",
                "Processor": "A12Z Bionic",
                "Memory": "6 GB",
                "Storage": "128 GB, 256 GB, 512 GB, 1 TB",
                "Display": "11-inch Liquid Retina display",
                "Operating System": "iPadOS 13.4, upgradable to latest",
                "Colors": "Space Gray, Silver"
            ]
        ),
        Device(
            name: "iPad Pro (12.9-inch) (5th generation)",
            releaseDate: "March 25, 2020",
            specifications: [
                "Model Numbers": "A2229 (iPad8,11), A2069, A2232, A2233 (iPad8,12)",
                "Processor": "A12Z Bionic",
                "Memory": "6 GB",
                "Storage": "128 GB, 256 GB, 512 GB, 1 TB",
                "Display": "12.9-inch Liquid Retina display",
                "Operating System": "iPadOS 13.4, upgradable to latest",
                "Colors": "Space Gray, Silver"
            ]
        ),
        Device(
            name: "iPad (8th generation)",
            releaseDate: "September 18, 2020",
            specifications: [
                "Model Numbers": "A2270 (iPad11,6), A2428 (iPad11,7)",
                "Processor": "A12 Bionic",
                "Memory": "3 GB",
                "Storage": "32 GB, 128 GB",
                "Display": "10.2-inch Retina display",
                "Operating System": "iPadOS 14, upgradable to latest",
                "Colors": "Space Gray, Silver, Gold"
            ]
        ),
        Device(
            name: "iPad Air (4th generation)",
            releaseDate: "October 23, 2020",
            specifications: [
                "Model Numbers": "A2316 (iPad13,1), A2324, A2325, A2072 (iPad13,2)",
                "Processor": "A14 Bionic",
                "Memory": "4 GB",
                "Storage": "64 GB, 256 GB",
                "Display": "10.9-inch Liquid Retina display",
                "Operating System": "iPadOS 14, upgradable to latest",
                "Colors": "Space Gray, Silver, Rose Gold, Green, Sky Blue"
            ]
        ),
        
        // Current iPads (2021-2023)
        Device(
            name: "iPad Pro (11-inch) (3rd generation)",
            releaseDate: "May 21, 2021",
            specifications: [
                "Model Numbers": "A2377 (iPad13,4), A2459, A2301, A2460",
                "Processor": "Apple M1",
                "Memory": "8 GB or 16 GB",
                "Storage": "128 GB, 256 GB, 512 GB, 1 TB, 2 TB",
                "Display": "11-inch Liquid Retina display",
                "Operating System": "iPadOS 14.5, upgradable to latest",
                "Colors": "Space Gray, Silver"
            ]
        ),
        Device(
            name: "iPad Pro (12.9-inch) (6th generation)",
            releaseDate: "May 21, 2021",
            specifications: [
                "Model Numbers": "A2378 (iPad13,8), A2461, A2379, A2462",
                "Processor": "Apple M1",
                "Memory": "8 GB or 16 GB",
                "Storage": "128 GB, 256 GB, 512 GB, 1 TB, 2 TB",
                "Display": "12.9-inch Liquid Retina XDR display",
                "Operating System": "iPadOS 14.5, upgradable to latest",
                "Colors": "Space Gray, Silver"
            ]
        ),
        Device(
            name: "iPad mini (6th generation)",
            releaseDate: "September 24, 2021",
            specifications: [
                "Model Numbers": "A2567 (iPad14,1), A2568, A2569 (iPad14,2)",
                "Processor": "A15 Bionic",
                "Memory": "4 GB",
                "Storage": "64 GB, 256 GB",
                "Display": "8.3-inch Liquid Retina display",
                "Operating System": "iPadOS 15, upgradable to latest",
                "Colors": "Space Gray, Pink, Purple, Starlight"
            ]
        ),
        Device(
            name: "iPad (9th generation)",
            releaseDate: "September 24, 2021",
            specifications: [
                "Model Numbers": "A2602 (iPad14,3), A2604 (iPad14,4)",
                "Processor": "A13 Bionic",
                "Memory": "3 GB",
                "Storage": "64 GB, 256 GB",
                "Display": "10.2-inch Retina display",
                "Operating System": "iPadOS 15, upgradable to latest",
                "Colors": "Space Gray, Silver"
            ]
        ),
        Device(
            name: "iPad Air (5th generation)",
            releaseDate: "March 18, 2022",
            specifications: [
                "Model Numbers": "A2588 (iPad13,16), A2589, A2591 (iPad13,17)",
                "Processor": "Apple M1",
                "Memory": "8 GB",
                "Storage": "64 GB, 256 GB",
                "Display": "10.9-inch Liquid Retina display",
                "Operating System": "iPadOS 15.4, upgradable to latest",
                "Colors": "Space Gray, Starlight, Pink, Purple, Blue"
            ]
        ),
        Device(
            name: "iPad (10th generation)",
            releaseDate: "October 26, 2022",
            specifications: [
                "Model Numbers": "A2696 (iPad14,5), A2757 (iPad14,6)",
                "Processor": "A14 Bionic",
                "Memory": "4 GB",
                "Storage": "64 GB, 256 GB",
                "Display": "10.9-inch Liquid Retina display",
                "Operating System": "iPadOS 16, upgradable to latest",
                "Colors": "Space Gray, Silver, Pink, Blue, Yellow"
            ]
        ),
        
        // Newer iPads (2024-2025)
        Device(
            name: "iPad Air (6th generation)",
            releaseDate: "May 7, 2024",
            specifications: [
                "Model Numbers": "A3118 (iPad15,1), A3119 (iPad15,2)",
                "Processor": "Apple M2",
                "Memory": "8 GB",
                "Storage": "128 GB, 256 GB, 512 GB, 1 TB",
                "Display": "11-inch Liquid Retina display",
                "Operating System": "iPadOS 17.4, upgradable to latest",
                "Colors": "Space Gray, Starlight, Pink, Purple, Blue"
            ]
        ),
        Device(
            name: "iPad Pro (11-inch) (4th generation)",
            releaseDate: "October 22, 2024",
            specifications: [
                "Model Numbers": "A3116 (iPad15,3), A3117 (iPad15,4)",
                "Processor": "Apple M4",
                "Memory": "8 GB or 16 GB",
                "Storage": "256 GB, 512 GB, 1 TB, 2 TB",
                "Display": "11-inch Liquid Retina XDR display",
                "Operating System": "iPadOS 17.4, upgradable to latest",
                "Colors": "Space Gray, Silver"
            ]
        ),
        Device(
            name: "iPad Pro (12.9-inch) (7th generation)",
            releaseDate: "October 22, 2024",
            specifications: [
                "Model Numbers": "A3114 (iPad15,5), A3115 (iPad15,6)",
                "Processor": "Apple M4",
                "Memory": "8 GB or 16 GB",
                "Storage": "256 GB, 512 GB, 1 TB, 2 TB",
                "Display": "12.9-inch Liquid Retina XDR display",
                "Operating System": "iPadOS 17.4, upgradable to latest",
                "Colors": "Space Gray, Silver"
            ]
        ),
        Device(
            name: "iPad (11th generation)",
            releaseDate: "October 22, 2024",
            specifications: [
                "Model Numbers": "A3112 (iPad16,1), A3113 (iPad16,2)",
                "Processor": "A17 Pro",
                "Memory": "8 GB",
                "Storage": "128 GB, 256 GB, 512 GB",
                "Display": "10.9-inch Liquid Retina display",
                "Operating System": "iPadOS 17.4, upgradable to latest",
                "Colors": "Space Gray, Silver, Pink, Blue, Yellow"
            ]
        )
    ]

    var body: some View {
        NavigationView {
            List(iPads) { iPad in
                NavigationLink(destination: DeviceDetailView(device: iPad)) {
                    Text(iPad.name)
                        .font(.headline)
                }
            }
            .navigationTitle("Supported iPads")
        }
    }
}
