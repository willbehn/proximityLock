//
//  proximityLockApp.swift
//  proximityLock
//
//  Created by William Behn on 13/10/2025.
//

import SwiftUI

@main
struct ProximityLockApp: App {
    @StateObject private var scanner = ScannerService()

    var body: some Scene {
        MenuBarExtra("BT Prox", systemImage: "lock") {
            ProximityLockView().environmentObject(scanner)
        }
        .menuBarExtraStyle(.window)
    }
}
