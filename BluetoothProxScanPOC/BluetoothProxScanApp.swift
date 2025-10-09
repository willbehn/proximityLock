//
//  BluetoothProxScanApp.swift
//  BluetoothProxScanPOC
//
//  Created by William Behn on 09/10/2025.
//

import SwiftUI

@main
struct BluetoothProxScanApp: App {
    @StateObject private var scanner = ScannerService()
    
    var body: some Scene {
        MenuBarExtra("BT Prox",
                     systemImage: "lock") {
            VStack(alignment: .leading, spacing: 12) {
                Toggle(isOn: $scanner.isOn) {
                    Text(scanner.isOn ? "Scanning: ON" : "Scanning: OFF")
                }
                .toggleStyle(.switch)
                .onChange(of: scanner.isOn) { oldValue, newValue in
                    
                    if newValue { scanner.start() } else { scanner.stop() }
                }
                
                Divider()
                Button("Quit") { NSApplication.shared.terminate(nil) }
            }
            .padding(12)
            .frame(width: 280)
        }
                     .menuBarExtraStyle(.window)
    }
}


