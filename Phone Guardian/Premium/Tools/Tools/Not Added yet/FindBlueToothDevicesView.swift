// FindBluetoothDevicesView.swift

import SwiftUI
import CoreBluetooth

struct FindBluetoothDevicesView: View {
    @StateObject private var bluetoothScanner = BluetoothScanner()
    
    var body: some View {
        VStack {
            Text("Find Bluetooth Devices")
                .font(.largeTitle)
                .padding()
            
            if bluetoothScanner.isScanning {
                ProgressView("Scanning for devices...")
                    .padding()
            }
            
            List(bluetoothScanner.discoveredDevices, id: \.identifier) { device in
                Text(device.name ?? "Unknown Device")
            }
            
            Spacer()
        }
        .onAppear {
            bluetoothScanner.startScanning()
        }
        .onDisappear {
            bluetoothScanner.stopScanning()
        }
        .navigationTitle("Find Bluetooth Devices")
    }
}

class BluetoothScanner: NSObject, ObservableObject, CBCentralManagerDelegate {
    @Published var discoveredDevices: [CBPeripheral] = []
    @Published var isScanning = false
    
    private var centralManager: CBCentralManager!
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScanning() {
        if centralManager.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: nil, options: nil)
            isScanning = true
        }
    }
    
    func stopScanning() {
        centralManager.stopScan()
        isScanning = false
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            startScanning()
        } else {
            isScanning = false
        }
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        if !discoveredDevices.contains(peripheral) {
            discoveredDevices.append(peripheral)
        }
    }
}
