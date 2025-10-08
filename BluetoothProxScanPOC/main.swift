//
//  main.swift
//  BluetoothProxScanPOC
//
//  Created by William Behn on 08/10/2025.
//

import Foundation
import CoreBluetooth

let appleLE0: UInt8 = 0x4C // Apple company ids
let appleLE1: UInt8 = 0x00

let nameTest: String = "william"

let runLoop = RunLoop.current

class Central: NSObject, CBCentralManagerDelegate {
    private var manager: CBCentralManager!

    override init() {
        super.init()
        manager = CBCentralManager(delegate: self, queue: DispatchQueue(label: "bt.queue"))
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("Bluetooth ON")
            manager.scanForPeripherals(withServices: nil,
                                       options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
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

        if let manufacturerKey = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data, manufacturerKey.count >= 2, manufacturerKey[0] == appleLE0, manufacturerKey[1] == appleLE1 {
            
            
            let name = (advertisementData[CBAdvertisementDataLocalNameKey] as? String)
            ?? peripheral.name ?? "Unknown"
            
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss"
            let currentTime = formatter.string(from: Date())
            
       
            let distance = calcDistanceWithRSSI(RSSI: RSSI)
            
            if name.lowercased().contains("william sin iphone") {
                print("[\(currentTime)][APPLE] RSSI=\(rssi) dBm distance \(distance) m name=\(name)")
            }
        }
    }
    
    func calcDistanceWithRSSI(RSSI: NSNumber) -> Double{
        let TxPower: Double = -50.0
        let pathLoss: Double = 2.0
        let rssiValue: Double = RSSI.doubleValue
        
        let distance = pow(10,(TxPower - rssiValue)/(10*pathLoss))
        
        return Double(round(1000*distance) / 1000)
    }
    
}

print("Bluetooth scanner dings")
let central = Central()
while runLoop.run(mode: .default, before: .distantFuture) { }
