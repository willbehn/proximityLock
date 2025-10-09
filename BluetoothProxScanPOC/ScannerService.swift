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

    private var scanner: BluetoothScanner?

    func start() {
        guard !isOn else { return }
        isOn = true
        scanner = BluetoothScanner()
        //scanner.?.startScanningIfReady() //It auto starts now
        
    }

    func stop() {
        guard isOn else { return }
        isOn = false
        scanner?.stopScanning()
        scanner = nil
    }
    
    func updateThreshold(value: Double) {
        scanner?.updateThreshold(newThreshold: value)
    }
}
