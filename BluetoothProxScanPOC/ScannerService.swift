//
//  ScannerService.swift
//  BluetoothProxScanPOC
//
//  Created by William Behn on 09/10/2025.
//

import Combine

@MainActor
final class ScannerService: ObservableObject {
    @Published var isOn = false
    @Published var threshold: Double
    
    private var scanner: BluetoothScanner = BluetoothScanner()
     
    init() {
        self.threshold = scanner.threshold
    }
    
    func start() {
        guard isOn else { return }
        
        isOn = true

        scanner.startScanningIfReady() 
        
    }

    func stop() {
        guard !isOn else { return }
        isOn = false
        scanner.stopScanning()
    }
    
    func updateThreshold() {
        print("ENDRER THRESHOLD")
        scanner.updateThreshold(newThreshold: self.threshold)
        
        self.threshold = scanner.threshold
    }
}
