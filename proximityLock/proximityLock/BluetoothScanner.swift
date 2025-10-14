//
//  main.swift
//  BluetoothProxScanPOC
//
//  Created by William Behn on 08/10/2025.
//

import Foundation
import CoreBluetooth
import Cocoa

import Foundation
import Combine

struct DeviceItem: Hashable, Identifiable {
    let id: String
    let name: String
}


struct KalmanFilterRSSI {
    private(set) var x: Double   // estimated RSSI
    private(set) var P: Double   // uncertainty
    private let Q: Double        // how much rssi should change
    private let R: Double        // noise

    init(initialRSSI: Double,
         processNoise: Double = 0.5,
         measurementNoise: Double = 4.0) {
        self.x = initialRSSI
        self.P = 10.0
        self.Q = processNoise
        self.R = measurementNoise
    }

    //math from chatGPT
    mutating func update(measuredRSSI z: Double) -> Double {
        // 1. Predict
        P = P + Q

        // 2. Compute Kalman gain
        let K = P / (P + R)

        // 3. Update estimate
        x = x + K * (z - x)

        // 4. Update uncertainty
        P = (1 - K) * P

        return x
    }
}

class BluetoothScanner: NSObject, CBCentralManagerDelegate {
    private var manager: CBCentralManager!
    private var startTime: Double? = nil
    private var stopAdTrigger: Bool = false
    
    private var unlockTime: Double? = nil
    
    private let lockCenter = DistributedNotificationCenter.default()
    private var isLocked: Bool = false
    
    
    // Id for apple enheter BT advertisement
    let appleLE0: UInt8 = 0x4C
    let appleLE1: UInt8 = 0x00

    private(set) var threshold: Double = -65
    private(set) var devices: Set<DeviceItem> = []
    
    let rssiPublisher = PassthroughSubject<Double, Never>()

    private var filter = KalmanFilterRSSI(initialRSSI: -70)
    
    let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss"
        return f
    }()

    override init() {
        super.init()
        manager = CBCentralManager(delegate: self, queue: DispatchQueue(label: "bt.queue"))

        
        
        lockCenter.addObserver(
            forName: NSNotification.Name("com.apple.screenIsLocked"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            print("screen is locked")
            self?.isLocked = true
            self?.stopScanning()
        }
        
        lockCenter.addObserver(
            forName: NSNotification.Name("com.apple.screenIsUnlocked"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            print("screen is unlocked")
            self?.isLocked = false
            self?.startScanningIfReady()
            self?.unlockTime = Date().timeIntervalSince1970
        }
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:     print("Bluetooth ON")
        case .poweredOff:    print("Bluetooth OFF")
        case .unauthorized:  print("unauthorized")
        case .unsupported:   print("unsupported")
        case .resetting:     print("resetting")
        case .unknown: fallthrough
        @unknown default:    print("unknown")
        }
    }
    

    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
   
    
        guard RSSI.intValue != 127 else { return }
        
        guard !isLocked else { return }
        
        if startTime == nil {startTime = Date().timeIntervalSince1970}
        
        let now = Date().timeIntervalSince1970

        if let lt = self.unlockTime, now - lt <= 60 { return }
        
        if let manufacturerKey = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data,
            manufacturerKey.count >= 2, manufacturerKey[0] == appleLE0, manufacturerKey[1] == appleLE1 {
            
            let name = (advertisementData[CBAdvertisementDataLocalNameKey] as? String)
            ?? peripheral.name ?? "Unknown"
            
            
            if let name = peripheral.name {
                devices.insert(DeviceItem(id: peripheral.identifier.uuidString, name: name))
            }
            
            
            if name.lowercased().contains("william sin iphone"){
                //print("[][APPLE] RSSI=\(rssi) dBm m name=\(name)")
                //print("id=\(peripheral.identifier.uuidString)")
                
                let smoothed = filter.update(measuredRSSI: RSSI.doubleValue)
                
                rssiPublisher.send(smoothed)
                
                print ("smoothed=\(smoothed) VS normal=\(RSSI.doubleValue)")
                
                guard (Date().timeIntervalSince1970 - (startTime ?? 0.0)) > 25 else { return }
        
                if smoothed < threshold{
                    print("LOCKING at \(Date()) rssi=\(smoothed)")
                    
                    startScreenSaver()
                    
                }
            }
        }
    }
    
    func startScanningIfReady() {
            if manager.state == .poweredOn {
                manager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
            }
        }

    func stopScanning() {
        manager.stopScan()
    }
    
    func updateThreshold(newThreshold: Double) {
        self.threshold = newThreshold
    }
}

func startScreenSaver() {
    let saverPath = "/System/Library/CoreServices/ScreenSaverEngine.app"
    let url = URL(fileURLWithPath: saverPath)
    let config = NSWorkspace.OpenConfiguration()

    DispatchQueue.main.async {
        NSWorkspace.shared.openApplication(at: url, configuration: config) { _, error in
            if let error = error {
                print("Error \(error)")
            }
        }
    }
}

