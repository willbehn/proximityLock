//
//  BluetoothProxScanApp.swift
//  BluetoothProxScanPOC
//
//  Created by William Behn on 09/10/2025.
//

import SwiftUI

struct ProximityLockView: View {
    @EnvironmentObject var scanner: ScannerService
    @State private var isEditing = false
    
    let minRSSI = -85.0
    let maxRSSI = -35.0
    
    var body: some View {
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
            
            RSSIChartView(scanner: scanner)
            
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Lock when RSSI is below \(Int(scanner.threshold)) dBm")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Less sensitive").font(.caption)
                        Text("−85 dBm").font(.caption2).foregroundStyle(.secondary)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("More sensitive").font(.caption)
                        Text("−35 dBm").font(.caption2).foregroundStyle(.secondary)
                    }
                }
                
                Slider(
                    value: $scanner.threshold,
                    in: minRSSI ... maxRSSI,
                    onEditingChanged: { editing in
                        isEditing = editing
                        
                        if !editing{
                            scanner.updateThreshold()
                        }
                    }
                )
            }
            
            
            
            
            Divider()
            
            
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Devices")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Button(action: {
                        scanner.updateDevices()
                    }) {
                        Label("Rescan", systemImage: "arrow.clockwise")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
                
                DevicePickerView(scanner: scanner)
            }
            
            Divider()
            
            Button(action: { NSApp.terminate(nil) }) {
                HStack {
                    Text("Quit Proximity Lock")
                    Spacer()
                    Text("⌘Q").foregroundStyle(.secondary)
                }
                .padding(.vertical, 6)
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .frame(width: 300)
    }
}
