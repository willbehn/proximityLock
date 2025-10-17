//
//  KalmanFilter.swift
//  proximityLock
//
//  Created by William Behn on 17/10/2025.
//

import Foundation

struct KalmanFilterRSSI {
    private(set) var x: Double   // estimated RSSI
    private(set) var P: Double   // uncertainty

    private let QperSecond: Double
    private let R: Double

    private let clipDelta: Double
    private var lastTime: TimeInterval?

    init(
        initialRSSI: Double,
        processNoisePerSecond: Double = 0.5,
        measurementNoise: Double = 4.0,
        initialUncertainty: Double = 10.0,
        outlierClipDelta: Double = 12.0
    ) {
        self.x = initialRSSI
        self.P = initialUncertainty
        self.QperSecond = processNoisePerSecond
        self.R = measurementNoise
        self.clipDelta = outlierClipDelta
        self.lastTime = nil
    }

    mutating func update(measuredRSSI raw: Double, time: TimeInterval) -> Double {
        let dt = timeDelta(from: time)
        
        P = P + QperSecond * dt

        let z = clamp(raw, to: (x - clipDelta)...(x + clipDelta))

        //Kalman gain
        let K = P / (P + R)

        x = x + K * (z - x)
        P = (1 - K) * P

        return x
    }

    private mutating func timeDelta(from t: TimeInterval) -> Double {
        defer {lastTime = t} 
        guard let last = lastTime else { return 0 }
        return max(0, t - last)
    }

    private func clamp(_ v: Double, to r: ClosedRange<Double>) -> Double {
        min(max(v, r.lowerBound), r.upperBound)
    }
}
