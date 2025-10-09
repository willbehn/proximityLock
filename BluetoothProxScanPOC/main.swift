//
//  main.swift
//  BluetoothProxScanPOC
//
//  Created by William Behn on 08/10/2025.
//

import Foundation
import CoreBluetooth
import Cocoa

// Id for apple enheter BT advertisement
let appleLE0: UInt8 = 0x4C
let appleLE1: UInt8 = 0x00

let minRSSI: Double = -60


struct RSSIWindow {
    private var window: [Double] = []
    private var maxCount: Int
    
    init(maxCount: Int) {
        self.maxCount = maxCount
    }
    
    mutating func add(_ newRSSI: Double) {
        if window.count >= maxCount{
            window.removeFirst()
            
        }
        window.append(newRSSI)
    }
    
    func average() -> Double {
        guard window.count < maxCount else { return Double.greatestFiniteMagnitude }
        
        return window.reduce(0, +) / Double(window.count)
    }
}


class Central: NSObject, CBCentralManagerDelegate {
    private var manager: CBCentralManager!
    private var startTime: Double = Date().timeIntervalSince1970
    private var stopAdTrigger: Bool = false
    private var lockTime: Double = Date().timeIntervalSince1970
    
    private var window: RSSIWindow = RSSIWindow(maxCount: 10)
 
    var allRSSI: [Double] = []
    
    let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss"
        return f
    }()

    override init() {
        super.init()
        manager = CBCentralManager(delegate: self, queue: DispatchQueue(label: "bt.queue"))
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("Bluetooth ON")
            manager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
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
   
        let rssi = RSSI.intValue
        guard rssi != 127 else { return }
        
        if let manufacturerKey = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data,
            manufacturerKey.count >= 2, manufacturerKey[0] == appleLE0, manufacturerKey[1] == appleLE1 {
            
            let name = (advertisementData[CBAdvertisementDataLocalNameKey] as? String)
            ?? peripheral.name ?? "Unknown"
            
            allRSSI.append(RSSI.doubleValue)
            
            let currentTime = formatter.string(from: Date())
            let distance = calcDistanceWithRSSI(RSSI: RSSI)
            
            if name.lowercased().contains("william sin iphone"){
                print("[\(currentTime)][APPLE] RSSI=\(rssi) dBm m name=\(name)")
                print("     id=\(peripheral.identifier.uuidString)")
                print("     approximate distance=\(distance)")
                
                let currentTime = Date().timeIntervalSince1970
                
                window.add(RSSI.doubleValue)
                
                
                if currentTime - lockTime > 30 && window.average() < minRSSI{
                    stopAdTrigger = false
                }
                
                if window.average() < minRSSI && currentTime - startTime > 5 && !stopAdTrigger{
                    print("LOCKING at \(Date()) avg=\(window.average())")
                    
                    stopAdTrigger = true
                    lockTime = Date().timeIntervalSince1970
                    startScreenSaver()
                }
            }
        }
    }
    
    func calcDistanceWithRSSI(RSSI: NSNumber) -> Double {
        let TxPower: Double = -50.0
        let pathLoss: Double = 2.0
        let rssiValue: Double = RSSI.doubleValue
        
        let distance = pow(10,(TxPower - rssiValue)/(10*pathLoss))
        
        return Double(round(1000*distance) / 1000)
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


print("Bluetooth scanner dings")
let central = Central()

RunLoop.main.run()

