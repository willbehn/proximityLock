//
//  TestPlot.swift
//  BluetoothProxScanPOC
//
//  Created by William Behn on 13/10/2025.
//


import SwiftUI
import Charts

struct RSSIChartView: View {
    @ObservedObject var scanner: ScannerService

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Bluetooth RSSI (last \(scanner.lastObservations.count) samples)")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Chart {
                ForEach(Array(scanner.lastObservations.enumerated()), id: \.offset) { idx, rssi in
                    LineMark(
                        x: .value("Idx", idx),
                        y: .value("RSSI", rssi)
                    )
                }
                
                RuleMark(y: .value("Threshold", scanner.threshold))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4]))
                    .foregroundStyle(Color.secondary)
                    .annotation(position: .leading) {
                        Text("th")
                            .font(.caption2)
                            .foregroundStyle(.primary)
                    }
            }
            .chartYScale(domain: -85 ... -35)
            .chartXAxis(.hidden)
            .frame(height: 100)
            .padding(8)
            .background(.secondary.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 9))
        }
    }
}
