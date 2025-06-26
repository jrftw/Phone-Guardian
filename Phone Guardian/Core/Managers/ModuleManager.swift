import SwiftUI

class ModuleManager: ObservableObject {
    @Published var modules: [Module] = []

    private let modulesKey = "com.phoneguardian.modules"

    init() {
        loadModules()
    }

    // MARK: - Load Modules
    func loadModules() {
        if let data = UserDefaults.standard.data(forKey: modulesKey),
           let savedModules = try? JSONDecoder().decode([Module].self, from: data) {
            modules = savedModules
        } else {
            preloadModules()
        }
    }
    
    // MARK: - Force Refresh Modules
    func forceRefreshModules() {
        UserDefaults.standard.removeObject(forKey: modulesKey)
        preloadModules()
    }

    // MARK: - Preload Default Modules
    func preloadModules() {
        modules = [
            Module(name: "Device Info", viewName: "DeviceInfoView", isEnabled: true, description: "View detailed information about your device", iconName: "iphone"),
            Module(name: "Battery Info", viewName: "BatteryInfoView", isEnabled: true, description: "Monitor your battery health and usage", iconName: "battery.100"),
            Module(name: "CPU Info", viewName: "CPUInfoView", isEnabled: true, description: "Track CPU usage and performance", iconName: "cpu"),
            Module(name: "RAM Info", viewName: "RAMInfoView", isEnabled: true, description: "Monitor memory usage and availability", iconName: "memorychip"),
            Module(name: "Storage Info", viewName: "StorageInfoView", isEnabled: true, description: "Check storage space and usage", iconName: "externaldrive"),
            Module(name: "Network Info", viewName: "NetworkInfoView", isEnabled: true, description: "View network status and details", iconName: "network"),
            Module(name: "Sensors Info", viewName: "SensorInfoView", isEnabled: true, description: "Monitor device sensors and motion", iconName: "gyroscope"),
            Module(name: "Display Info", viewName: "DisplayInfoView", isEnabled: true, description: "Check display specifications and status", iconName: "display"),
            Module(name: "Camera Info", viewName: "CameraInfoView", isEnabled: true, description: "View camera specifications and status", iconName: "camera"),
            Module(name: "Health Check", viewName: "HealthCheckView", isEnabled: true, description: "Run a full device health check for issues and errors", iconName: "heart.text.square"),
            Module(name: "GPU Info", viewName: "GPUInfoView", isEnabled: true, description: "Monitor GPU load and rendering", iconName: "gpu"),
            Module(name: "Thermal Info", viewName: "ThermalInfoView", isEnabled: true, description: "Track device thermal state", iconName: "thermometer")
        ]
        saveModules()
    }

    // MARK: - Save Modules
    func saveModules() {
        if let data = try? JSONEncoder().encode(modules) {
            UserDefaults.standard.set(data, forKey: modulesKey)
        }
    }

    // MARK: - Toggle Module
    func toggleModule(_ module: Module) {
        if let index = modules.firstIndex(where: { $0.id == module.id }) {
            modules[index].isEnabled.toggle()
            saveModules()
        }
    }

    // MARK: - Update Module Order
    func updateModuleOrder(from source: IndexSet, to destination: Int) {
        modules.move(fromOffsets: source, toOffset: destination)
        saveModules()
    }
}
