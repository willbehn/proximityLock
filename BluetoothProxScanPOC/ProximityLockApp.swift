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
                
                HStack(spacing: 8) {
                    Image(systemName: "lock.circle.fill")
                        .imageScale(.large)
                    Text("Proximity Lock")
                        .font(.headline)
                    
                    Spacer()
                    
                    Label(scanner.isOn ? "On" : "Off",
                          systemImage: "circle.fill")
                    .labelStyle(.titleAndIcon)
                    .foregroundStyle(scanner.isOn ? .green : .secondary)
                    .help("Scanner status")
                    
                    Toggle(isOn: $scanner.isOn) {
                       
                    }
                    .toggleStyle(.switch)
                    .onChange(of: scanner.isOn) { oldValue, newValue in
                        
                        if newValue { scanner.start() } else { scanner.stop() }
                    }
                }
                
                HStack {
                    Text("Lock Threshold")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Text("\(scanner.threshold, specifier: "%.1f") dB")
                        .font(.system(.subheadline, design: .rounded))
                    
                        .foregroundStyle(.secondary)
                }
                
                Text("(Higher value is less sensitive)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    
                
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
                
                HStack {
                    Text("-85 dB")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text("-55 dB")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                
                Divider()
                
                Button("Quit") { NSApplication.shared.terminate(nil) }
                    .buttonStyle(.bordered)
            }
            .padding(12)
            .frame(width: 300)
        }
                     .menuBarExtraStyle(.window)
    }
}


