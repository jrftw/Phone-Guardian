import SwiftUI
struct DetailediPhoneView: View {
    // MARK: - Device Data
    let iPhones: [Device] = [
        // iPhone 6
        Device(name: "iPhone 6", releaseDate: "September 19, 2014", specifications: [
            "Model Numbers": "A1549, A1586, A1589",
            "Processor": "A8 chip",
            "Camera": "8 MP",
            "Display": "4.7-inch",
            "Operating System": "iOS 8, upgradable to iOS 12.5.7"
        ]),
        // iPhone 6 Plus
        Device(name: "iPhone 6 Plus", releaseDate: "September 19, 2014", specifications: [
            "Model Numbers": "A1522, A1524, A1593",
            "Processor": "A8 chip",
            "Camera": "8 MP",
            "Display": "5.5-inch",
            "Operating System": "iOS 8, upgradable to iOS 12.5.7"
        ]),
        // iPhone 6s
        Device(name: "iPhone 6s", releaseDate: "September 25, 2015", specifications: [
            "Model Numbers": "A1633, A1688, A1691, A1700",
            "Processor": "A9 chip",
            "Camera": "12 MP",
            "Display": "4.7-inch",
            "Operating System": "iOS 9, upgradable to iOS 15.7"
        ]),
        // iPhone 6s Plus
        Device(name: "iPhone 6s Plus", releaseDate: "September 25, 2015", specifications: [
            "Model Numbers": "A1634, A1687, A1690, A1699",
            "Processor": "A9 chip",
            "Camera": "12 MP",
            "Display": "5.5-inch",
            "Operating System": "iOS 9, upgradable to iOS 15.7"
        ]),
        // iPhone SE (1st generation)
        Device(name: "iPhone SE (1st generation)", releaseDate: "March 31, 2016", specifications: [
            "Model Numbers": "A1662, A1723, A1724",
            "Processor": "A9 chip",
            "Camera": "12 MP",
            "Display": "4.0-inch",
            "Operating System": "iOS 9.3, upgradable to iOS 15.7"
        ]),
        // iPhone 7
        Device(name: "iPhone 7", releaseDate: "September 16, 2016", specifications: [
            "Model Numbers": "A1660, A1778, A1779, A1780",
            "Processor": "A10 Fusion",
            "Camera": "12 MP",
            "Display": "4.7-inch",
            "Operating System": "iOS 10, upgradable to iOS 15.7"
        ]),
        // iPhone 7 Plus
        Device(name: "iPhone 7 Plus", releaseDate: "September 16, 2016", specifications: [
            "Model Numbers": "A1661, A1784, A1785, A1786",
            "Processor": "A10 Fusion",
            "Camera": "Dual 12 MP",
            "Display": "5.5-inch",
            "Operating System": "iOS 10, upgradable to iOS 15.7"
        ]),
        // iPhone 8
        Device(name: "iPhone 8", releaseDate: "September 22, 2017", specifications: [
            "Model Numbers": "A1863, A1905, A1906, A1907",
            "Processor": "A11 Bionic",
            "Camera": "12 MP",
            "Display": "4.7-inch",
            "Operating System": "iOS 11, upgradable to iOS 16"
        ]),
        // iPhone 8 Plus
        Device(name: "iPhone 8 Plus", releaseDate: "September 22, 2017", specifications: [
            "Model Numbers": "A1864, A1897, A1898, A1899",
            "Processor": "A11 Bionic",
            "Camera": "Dual 12 MP",
            "Display": "5.5-inch",
            "Operating System": "iOS 11, upgradable to iOS 16"
        ]),
        // iPhone X
        Device(name: "iPhone X", releaseDate: "November 3, 2017", specifications: [
            "Model Numbers": "A1865, A1901, A1902",
            "Processor": "A11 Bionic",
            "Camera": "Dual 12 MP",
            "Display": "5.8-inch",
            "Operating System": "iOS 11, upgradable to iOS 16"
        ]),
        // iPhone XR
        Device(name: "iPhone XR", releaseDate: "October 26, 2018", specifications: [
            "Model Numbers": "A1984, A2105, A2106, A2108",
            "Processor": "A12 Bionic",
            "Camera": "12 MP",
            "Display": "6.1-inch",
            "Operating System": "iOS 12, upgradable to iOS 16"
        ]),
        // iPhone XS
        Device(name: "iPhone XS", releaseDate: "September 21, 2018", specifications: [
            "Model Numbers": "A1920, A2097, A2098, A2100",
            "Processor": "A12 Bionic",
            "Camera": "Dual 12 MP",
            "Display": "5.8-inch",
            "Operating System": "iOS 12, upgradable to iOS 16"
        ]),
        // iPhone XS Max
        Device(name: "iPhone XS Max", releaseDate: "September 21, 2018", specifications: [
            "Model Numbers": "A1921, A2101, A2102, A2103, A2104",
            "Processor": "A12 Bionic",
            "Camera": "Dual 12 MP",
            "Display": "6.5-inch",
            "Operating System": "iOS 12, upgradable to iOS 16"
        ]),
        // iPhone 11
        Device(name: "iPhone 11", releaseDate: "September 20, 2019", specifications: [
            "Model Numbers": "A2111, A2221, A2223",
            "Processor": "A13 Bionic",
            "Camera": "Dual 12 MP",
            "Display": "6.1-inch",
            "Operating System": "iOS 13, upgradable to iOS 16"
        ]),
        // iPhone 11 Pro
        Device(name: "iPhone 11 Pro", releaseDate: "September 20, 2019", specifications: [
            "Model Numbers": "A2160, A2215, A2217",
            "Processor": "A13 Bionic",
            "Camera": "Triple 12 MP",
            "Display": "5.8-inch",
            "Operating System": "iOS 13, upgradable to iOS 16"
        ]),
        // iPhone 11 Pro Max
        Device(name: "iPhone 11 Pro Max", releaseDate: "September 20, 2019", specifications: [
            "Model Numbers": "A2161, A2220, A2218",
            "Processor": "A13 Bionic",
            "Camera": "Triple 12 MP",
            "Display": "6.5-inch",
            "Operating System": "iOS 13, upgradable to iOS 16"
        ]),
        // iPhone SE (2nd generation)
        Device(name: "iPhone SE (2nd generation)", releaseDate: "April 24, 2020", specifications: [
            "Model Numbers": "A2275, A2296, A2298",
            "Processor": "A13 Bionic",
            "Camera": "12 MP",
            "Display": "4.7-inch",
            "Operating System": "iOS 13, upgradable to iOS 16"
        ]),
        // iPhone 12 mini
        Device(name: "iPhone 12 mini", releaseDate: "November 13, 2020", specifications: [
            "Model Numbers": "A2176, A2398, A2400, A2399",
            "Processor": "A14 Bionic",
            "Camera": "Dual 12 MP",
            "Display": "5.4-inch",
            "Operating System": "iOS 14, upgradable to iOS 16"
        ]),
        // iPhone 12
        Device(name: "iPhone 12", releaseDate: "October 23, 2020", specifications: [
            "Model Numbers": "A2172, A2402, A2404, A2403",
            "Processor": "A14 Bionic",
            "Camera": "Dual 12 MP",
            "Display": "6.1-inch",
            "Operating System": "iOS 14, upgradable to iOS 16"
        ]),
        // iPhone 12 Pro
        Device(name: "iPhone 12 Pro", releaseDate: "October 23, 2020", specifications: [
            "Model Numbers": "A2341, A2406, A2407, A2408",
            "Processor": "A14 Bionic",
            "Camera": "Triple 12 MP",
            "Display": "6.1-inch",
            "Operating System": "iOS 14, upgradable to iOS 16"
        ]),
        // iPhone 12 Pro Max
        Device(name: "iPhone 12 Pro Max", releaseDate: "November 13, 2020", specifications: [
            "Model Numbers": "A2342, A2410, A2411, A2412",
            "Processor": "A14 Bionic",
            "Camera": "Triple 12 MP",
            "Display": "6.7-inch",
            "Operating System": "iOS 14, upgradable to iOS 16"
        ]),
        // iPhone 13 mini
        Device(name: "iPhone 13 mini", releaseDate: "September 24, 2021", specifications: [
            "Model Numbers": "A2481, A2626, A2629, A2630, A2628",
            "Processor": "A15 Bionic",
            "Camera": "Dual 12 MP",
            "Display": "5.4-inch",
            "Operating System": "iOS 15, upgradable to iOS 16"
        ]),
        // iPhone 13
        Device(name: "iPhone 13", releaseDate: "September 24, 2021", specifications: [
            "Model Numbers": "A2482, A2631, A2634, A2635, A2633",
            "Processor": "A15 Bionic",
            "Camera": "Dual 12 MP",
            "Display": "6.1-inch",
            "Operating System": "iOS 15, upgradable to iOS 16"
        ]),
        // iPhone 13 Pro
        Device(name: "iPhone 13 Pro", releaseDate: "September 24, 2021", specifications: [
            "Model Numbers": "A2483, A2636, A2639, A2640, A2638",
            "Processor": "A15 Bionic",
            "Camera": "Triple 12 MP",
            "Display": "6.1-inch",
            "Operating System": "iOS 15, upgradable to iOS 16"
        ]),
        // iPhone 13 Pro Max
        Device(name: "iPhone 13 Pro Max", releaseDate: "September 24, 2021", specifications: [
            "Model Numbers": "A2484, A2641, A2644, A2645, A2643",
            "Processor": "A15 Bionic",
            "Camera": "Triple 12 MP",
            "Display": "6.7-inch",
            "Operating System": "iOS 15, upgradable to iOS 16"
        ]),
        // iPhone SE (3rd generation)
        Device(name: "iPhone SE (3rd generation)", releaseDate: "March 18, 2022", specifications: [
            "Model Numbers": "A2595, A2782, A2783, A2784, A2785",
            "Processor": "A15 Bionic",
            "Camera": "12 MP",
            "Display": "4.7-inch",
            "Operating System": "iOS 15, upgradable to iOS 16"
        ]),
        // iPhone 14
        Device(name: "iPhone 14", releaseDate: "September 16, 2022", specifications: [
            "Model Numbers": "A2649, A2881, A2882, A2883, A2884",
            "Processor": "A15 Bionic",
            "Camera": "Dual 12 MP",
            "Display": "6.1-inch",
            "Operating System": "iOS 16"
        ]),
        // iPhone 14 Plus
        Device(name: "iPhone 14 Plus", releaseDate: "October 7, 2022", specifications: [
            "Model Numbers": "A2632, A2885, A2886, A2887, A2888",
            "Processor": "A15 Bionic",
            "Camera": "Dual 12 MP",
            "Display": "6.7-inch",
            "Operating System": "iOS 16"
        ]),
        // iPhone 14 Pro
        Device(name: "iPhone 14 Pro", releaseDate: "September 16, 2022", specifications: [
            "Model Numbers": "A2650, A2889, A2890, A2891, A2892",
            "Processor": "A16 Bionic",
            "Camera": "Triple 48 MP",
            "Display": "6.1-inch",
            "Operating System": "iOS 16"
        ]),
        // iPhone 14 Pro Max
        Device(name: "iPhone 14 Pro Max", releaseDate: "September 16, 2022", specifications: [
            "Model Numbers": "A2651, A2893, A2894, A2895, A2896",
            "Processor": "A16 Bionic",
            "Camera": "Triple 48 MP",
            "Display": "6.7-inch",
            "Operating System": "iOS 16"
        ]),
        Device(
            name: "iPhone 15",
            releaseDate: "September 22, 2023",
            specifications: [
                "Model Numbers": "A3090, A3094",
                "Processor": "A16 Bionic chip with 6-core CPU, 5-core GPU, and 16-core Neural Engine",
                "Memory": "6 GB",
                "Storage": "128 GB, 256 GB, 512 GB",
                "Display": "6.1-inch Super Retina XDR display with 2556-by-1179-pixel resolution at 460 ppi",
                "Operating System": "iOS 17, upgradable to latest",
                "Colors": "Black, Blue, Green, Yellow, Pink",
                "Camera": "Advanced dual-camera system with 48MP Main and 12MP Ultra Wide lenses",
                "Battery Life": "Up to 20 hours video playback",
                "Connectivity": "5G, Wi-Fi 6, Bluetooth 5.3",
                "Dimensions": "Height: 5.81 inches; Width: 2.82 inches; Depth: 0.31 inch; Weight: 6.02 ounces",
                "Other Features": "Face ID, MagSafe wireless charging up to 15W, Emergency SOS via satellite"
            ]
        ),
        Device(
            name: "iPhone 15 Pro",
            releaseDate: "September 22, 2023",
            specifications: [
                "Model Numbers": "A3102, A3106",
                "Processor": "A17 Pro chip with 6-core CPU, 6-core GPU, and 16-core Neural Engine",
                "Memory": "8 GB",
                "Storage": "128 GB, 256 GB, 512 GB, 1 TB",
                "Display": "6.1-inch Super Retina XDR display with 2556-by-1179-pixel resolution at 460 ppi",
                "Operating System": "iOS 17, upgradable to latest",
                "Colors": "Black Titanium, White Titanium, Blue Titanium, Natural Titanium",
                "Camera": "Triple 48MP Main, 12MP Ultra Wide, 12MP Telephoto lenses; 12MP TrueDepth front camera",
                "Battery Life": "Up to 23 hours video playback",
                "Connectivity": "5G, Wi-Fi 6E, Bluetooth 5.3",
                "Dimensions": "Height: 5.77 inches; Width: 2.78 inches; Depth: 0.32 inch; Weight: 6.60 ounces",
                "Other Features": "Face ID, MagSafe wireless charging up to 15W, Emergency SOS via satellite"
            ]
        ),

        Device(
            name: "iPhone 15 Pro Max",
            releaseDate: "September 22, 2023",
            specifications: [
                "Model Numbers": "A3102, A3106",
                "Processor": "A17 Pro chip with 6-core CPU, 6-core GPU, and 16-core Neural Engine",
                "Memory": "8 GB",
                "Storage": "256 GB, 512 GB, 1 TB",
                "Display": "6.7-inch Super Retina XDR display with 2796-by-1290-pixel resolution at 460 ppi",
                "Operating System": "iOS 17, upgradable to latest",
                "Colors": "Black Titanium, White Titanium, Blue Titanium, Natural Titanium",
                "Camera": "Triple 48MP Main, 12MP Ultra Wide, 12MP Telephoto lenses; 12MP TrueDepth front camera",
                "Battery Life": "Up to 29 hours video playback",
                "Connectivity": "5G, Wi-Fi 6E, Bluetooth 5.3",
                "Dimensions": "Height: 6.29 inches; Width: 3.02 inches; Depth: 0.32 inch; Weight: 7.81 ounces",
                "Other Features": "Face ID, MagSafe wireless charging up to 15W, Emergency SOS via satellite"
            ]
        ),

        Device(
            name: "iPhone 16",
            releaseDate: "September 20, 2024",
            specifications: [
                "Model Numbers": "A3287, A3290",
                "Processor": "A18 chip with new 6-core CPU, 5-core GPU, and 16-core Neural Engine",
                "Memory": "8 GB",
                "Storage": "128 GB, 256 GB, 512 GB",
                "Display": "6.1-inch Super Retina XDR display with 2556-by-1179-pixel resolution at 460 ppi",
                "Operating System": "iOS 18, upgradable to latest",
                "Colors": "Black, White, Pink, Teal, Ultramarine",
                "Camera": "Advanced dual-camera system with 48MP Main and 12MP Ultra Wide lenses; 12MP TrueDepth front camera",
                "Battery Life": "Up to 22 hours video playback",
                "Connectivity": "5G, Wi-Fi 7, Bluetooth 5.3",
                "Dimensions": "Height: 5.81 inches; Width: 2.82 inches; Depth: 0.31 inch; Weight: 6.00 ounces",
                "Other Features": "Face ID, MagSafe wireless charging up to 25W, Emergency SOS, Crash Detection, Camera Control button"
            ]
        ),
        Device(
            name: "iPhone 16 Pro",
            releaseDate: "September 20, 2024",
            specifications: [
                "Model Numbers": "A3287, A3290",
                "Processor": "A18 Pro chip with 6-core CPU, 6-core GPU, and 16-core Neural Engine",
                "Memory": "8 GB",
                "Storage": "128 GB, 256 GB, 512 GB, 1 TB",
                "Display": "6.3-inch Super Retina XDR display with 2622-by-1206-pixel resolution at 460 ppi",
                "Operating System": "iOS 18, upgradable to latest",
                "Colors": "Black Titanium, White Titanium, Natural Titanium, Desert Titanium",
                "Camera": "Triple 48MP Main, 48MP Ultra Wide, 12MP Telephoto lenses; 12MP TrueDepth front camera",
                "Battery Life": "Up to 23 hours video playback",
                "Connectivity": "5G, Wi-Fi 7, Bluetooth 5.3",
                "Dimensions": "Height: 5.89 inches; Width: 2.81 inches; Depth: 0.32 inch; Weight: 7.03 ounces",
                "Other Features": "Face ID, MagSafe wireless charging up to 15W, Emergency SOS via satellite"
            ]
        ),

        Device(
            name: "iPhone 16 Pro Max",
            releaseDate: "September 20, 2024",
            specifications: [
                "Model Numbers": "A3287, A3290",
                "Processor": "A18 Pro chip with 6-core CPU, 6-core GPU, and 16-core Neural Engine",
                "Memory": "8 GB",
                "Storage": "256 GB, 512 GB, 1 TB",
                "Display": "6.9-inch Super Retina XDR display with 2868-by-1320-pixel resolution at 460 ppi",
                "Operating System": "iOS 18, upgradable to latest",
                "Colors": "Black Titanium, White Titanium, Natural Titanium, Desert Titanium",
                "Camera": "Triple 48MP Main, 48MP Ultra Wide, 12MP Telephoto lenses; 12MP TrueDepth front camera",
                "Battery Life": "Up to 29 hours video playback",
                "Connectivity": "5G, Wi-Fi 7, Bluetooth 5.3",
                "Dimensions": "Height: 6.42 inches; Width: 3.06 inches; Depth: 0.32 inch; Weight: 7.99 ounces",
                "Other Features": "Face ID, MagSafe wireless charging up to 15W, Emergency SOS via satellite"
            ]
        )

        // Placeholder for future models
        // Leave room to add the 15 series & 16 series
    ]
    
    var body: some View {
        NavigationView {
            List(iPhones) { iPhone in
                NavigationLink(destination: DeviceDetailView(device: iPhone)) {
                    Text(iPhone.name)
                        .font(.headline)
                }
            }
            .navigationTitle("Supported iPhones")
        }
    }
}
