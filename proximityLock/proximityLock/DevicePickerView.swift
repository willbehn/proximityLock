//
//  DeviceList.swift
//  BluetoothProxScanPOC
//
//  Created by William Behn on 13/10/2025.
//

import SwiftUI

struct DevicePickerView: View {
    @State private var devices: [DeviceItem] = []
    @State private var selectedID: String? = nil
    
    @ObservedObject var scanner: ScannerService
    
    var sortedDevices: [DeviceItem] {
        scanner.devices
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
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
            
            Text("Choose Device")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(sortedDevices) { device in
                        let isSelected = (selectedID == device.id)

                        Button {
                            selectedID = device.id
                            scanner.selectDevice(device)
                        } label: {
                            HStack(spacing: 8) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(device.name)
                                        .font(.subheadline)
                                }

                                Spacer()

                                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                    .imageScale(.medium)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(.plain)
                    }.padding(.vertical, 2)
                }
                .padding(.vertical, 2)
            }
            .frame(height: 120)
        }
    }
}

