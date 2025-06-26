import Foundation

class DeviceDataStore {
    static let shared = DeviceDataStore()

    private let devices: [String: Device] = [
        // iPhone Data
        "iPhone8,1": Device(
            name: "iPhone 6s",
            releaseDate: "September 25, 2015",
            specifications: [
                "Processor": "Apple A9",
                "RAM": "2GB",
                "Display": "4.7-inch Retina HD",
                "Storage": "16GB, 32GB, 64GB, 128GB",
                "Camera": "12 MP rear, 5 MP front",
                "OS": "iOS 9 (shipped)"
            ]
        ),
        "iPhone8,2": Device(
            name: "iPhone 6s Plus",
            releaseDate: "September 25, 2015",
            specifications: [
                "Processor": "Apple A9",
                "RAM": "2GB",
                "Display": "5.5-inch Retina HD",
                "Storage": "16GB, 32GB, 64GB, 128GB",
                "Camera": "12 MP rear, 5 MP front",
                "OS": "iOS 9 (shipped)"
            ]
        ),
        // Add other devices here...

        // iPad Data
        "iPad7,11": Device(
            name: "iPad (7th generation)",
            releaseDate: "September 25, 2019",
            specifications: [
                "Processor": "Apple A10 Fusion",
                "RAM": "3GB",
                "Display": "10.2-inch Retina",
                "Storage": "32GB, 128GB",
                "Camera": "8 MP rear, 1.2 MP front",
                "OS": "iPadOS 13 (shipped)"
            ]
        ),
        // Add other iPads...

        // Mac Data
        "MacBookAir10,1": Device(
            name: "MacBook Air (M1, 2020)",
            releaseDate: "November 17, 2020",
            specifications: [
                "Processor": "Apple M1",
                "RAM": "8GB, 16GB",
                "Storage": "256GB, 512GB, 1TB, 2TB",
                "Display": "13.3-inch Retina",
                "OS": "macOS 11 Big Sur (shipped)"
            ]
        ),
        // Add other Macs...

        // Vision Pro Data
        "Vision1,1": Device(
            name: "Apple Vision Pro",
            releaseDate: "Expected early 2024",
            specifications: [
                "Processor": "Apple M2",
                "RAM": "16GB",
                "Storage": "128GB",
                "Display": "Micro-OLED",
                "OS": "visionOS 1.0 (shipped)"
            ]
        )
    ]

    private init() {}

    func getDevice(for modelCode: String) -> Device? {
        return devices[modelCode]
    }
}
