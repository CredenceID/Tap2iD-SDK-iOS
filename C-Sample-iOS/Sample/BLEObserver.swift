//
//  BLEObserver.swift
//  Sample
//
//  Created by Deeprajj on 17/07/24.
//

import Foundation
import CoreBluetooth
import Combine

class BLEObserver: NSObject, ObservableObject {

    private var centralManager: CBCentralManager?
    @Published var bleState: CBManagerState = .unknown

    override init() {
        super.init()
        startCentralManager()
    }

    func startCentralManager() {
        centralManager = CBCentralManager(delegate: self, queue: .main, options: [CBCentralManagerOptionShowPowerAlertKey: true])
    }
}

extension BLEObserver: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        bleState = central.state
    }
}

