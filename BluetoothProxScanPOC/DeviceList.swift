//
//  DeviceList.swift
//  BluetoothProxScanPOC
//
//  Created by William Behn on 13/10/2025.
//

import SwiftUI

private struct DeviceItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let kind: String
    let symbol: String

    static let mock: [DeviceItem] = [
        .init(name: "William’s iPhone", kind: "Phone",       symbol: "iphone"),
        .init(name: "AirPods Pro",      kind: "Headphones",  symbol: "airpods.pro"),
        .init(name: "Apple Watch",      kind: "Watch",       symbol: "applewatch.watchface"),
        .init(name: "iPad",      kind: "Tablet",      symbol: "ipad"),
    ]
}

struct DevicePickerView: View {
    // Internal state only (no parameters)
    @State private var devices: [DeviceItem] = DeviceItem.mock
    @State private var selectedID: UUID? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Choose Device")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            ScrollView {
                LazyVStack(spacing: 6) {
                    ForEach(devices) { device in
                        let isSelected = (selectedID == device.id)

                        Button {
                            selectedID = device.id
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: device.symbol)
                                    .imageScale(.medium)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(device.name)
                                        .font(.subheadline)
                                    Text(device.kind)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                    .imageScale(.medium)
                    
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 2)
            }
            .frame(height: 120) // scrollable area
        }
    }
}
