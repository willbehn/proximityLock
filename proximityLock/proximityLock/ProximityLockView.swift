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
        VStack() {
            
            
            
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
                
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Lock threshold")
                                .font(.subheadline.weight(.semibold))
                            Text("Lock when RSSI is below \(Int(scanner.threshold)) dBm")
                                .font(.caption)
                                .monospacedDigit()
                        }
                        Spacer()
                        Text("\(Int(scanner.threshold)) dBm")
                            .font(.caption2.weight(.semibold))
                            .monospacedDigit()
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                        
                    }
                    
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
                            if !editing { scanner.updateThreshold() }
                        }
                    )
                    .tint(.accentColor)
                }
                .padding(12)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.quaternary, lineWidth: 1)
                )
                
                RSSIChartView(scanner: scanner)
                    .padding(12)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.quaternary, lineWidth: 1)
                    )
                
                
                
                DevicePickerView(scanner: scanner).padding(12)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.quaternary, lineWidth: 1)
                    )
                
                
                
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
        } //.background(Color(.windowBackgroundColor))
    }
}


