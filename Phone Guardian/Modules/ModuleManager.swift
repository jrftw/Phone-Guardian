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

    // MARK: - Preload Default Modules
    func preloadModules() {
        modules = [
            Module(name: "Device Info", viewName: "DeviceInfoView", isEnabled: true),
            Module(name: "Battery Info", viewName: "BatteryInfoView", isEnabled: true),
            Module(name: "CPU Info", viewName: "CPUInfoView", isEnabled: true),
            Module(name: "RAM Info", viewName: "RAMInfoView", isEnabled: true),
            Module(name: "Storage Info", viewName: "StorageInfoView", isEnabled: true),
            Module(name: "Network Info", viewName: "NetworkInfoView", isEnabled: true),
            Module(name: "Sensors Info", viewName: "SensorInfoView", isEnabled: true),
            Module(name: "Display Info", viewName: "DisplayInfoView", isEnabled: true),
            Module(name: "Camera Info", viewName: "CameraInfoView", isEnabled: true)
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
