//
//  ScannerService.swift
//  BluetoothProxScanPOC
//
//  Created by William Behn on 09/10/2025.
//

import Combine
import Dispatch

struct RSSIWindow {
    private var window: [Double] = []
    var maxCount: Int
    var count: Int { window.count }

    init(maxCount: Int) {
        self.maxCount = maxCount
    }
    
    var values: [Double] { window }
    
    mutating func add(_ newRSSI: Double) {
        if window.count >= maxCount {
            window.removeFirst()
        }
        window.append(newRSSI)
    }
    
    func average() -> Double? {
        guard !window.isEmpty else { return nil }
        return window.reduce(0, +) / Double(window.count)
    }
}

@MainActor
final class ScannerService: ObservableObject {
    private let sampleCount: Int = 30
    
    @Published var isOn = false
    @Published var threshold: Double
    @Published var lastObservations: [Double]
    private var samples: RSSIWindow
    
    private var scanner: BluetoothScanner = BluetoothScanner()
    
    private var rssiCancellable: AnyCancellable?
    
    private var publishEvery: Int = 4
    private var tick: Int = 0
     
    init() {
        self.threshold = scanner.threshold
        self.samples = RSSIWindow(maxCount: sampleCount)
        self.lastObservations = []
    }
    
    func start() {
        guard isOn else { return }
        
        isOn = true

        scanner.startScanningIfReady()
        
        self.rssiCancellable = scanner.rssiPublisher
            .receive(on: DispatchQueue.main)
            .sink{
                [weak self] rssi in
                
                guard let self else {return }
                self.samples.add(rssi)
                
                self.tick &+= 1
                
                if self.tick % self.publishEvery == 0, self.samples.values.count == self.sampleCount{
                    self.lastObservations = self.samples.values
                }
            }
    }

    func stop() {
        guard !isOn else { return }
        isOn = false
        rssiCancellable = nil
        scanner.stopScanning()
    }
    
    func updateThreshold() {
        scanner.updateThreshold(newThreshold: self.threshold)
        
        self.threshold = scanner.threshold
    }
}
