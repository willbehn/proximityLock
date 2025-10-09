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
    
    @State private var isEditing = false
    
    
    var body: some Scene {
        MenuBarExtra("BT Prox",
                     systemImage: "lock") {
            VStack(alignment: .leading, spacing: 12) {
                Text("Proximty lock")
                
                Toggle(isOn: $scanner.isOn) {
                    Text(scanner.isOn ? "Scanning: ON" : "Scanning: OFF")
                }
                .toggleStyle(.switch)
                .onChange(of: scanner.isOn) { oldValue, newValue in
                    
                    if newValue { scanner.start() } else { scanner.stop() }
                }
                
                
                Text("Threshold for locking (higher number is less sensitive)")
                Slider(
                    value: $scanner.threshold,
                    in: -85 ... -55,
                    onEditingChanged: { editing in
                        isEditing = editing
                        
                        if !editing{
                            scanner.updateThreshold()
                        }
                        
                    }
                )
                Text("\(scanner.threshold, specifier: "%.1f") dB")
                
                
                
                Divider()
                Button("Quit") { NSApplication.shared.terminate(nil) }
            }
            .padding(12)
            .frame(width: 280)
        }
                     .menuBarExtraStyle(.window)
    }
}


