//
//  WizardViewModel.swift
//  Meshtastic
//
//  Created by lzamaraev on 09.08.2021.
//

import Foundation
import CoreBluetooth

class WizardViewModel: BaseViewModel {

    let bleManager: BLEManagerProtocol = BLEManager.shared
    @Published var devices: [CBPeripheral] = []
    func scanForDevices() {
        loading = true
        bleManager.scan(for: 5) { founded in
            self.devices = founded
            self.loading = false
        }
    }

    func rescan() {
        loading = true
        bleManager.rescan { founded in
            self.devices = founded
            self.loading = false
        }
    }

    func connect(to device: CBPeripheral) {
        loading = true
        bleManager.connect(device: device) { result in
            self.loading = false
            if result {
                log("Connected to \(device.identifier)")
            } else {
                self.failure = "Connection to \(device.identifier) failed, try again."
                self.error = true
            }
        }
    }
}

class BaseViewModel: ObservableObject {

    @Published var loading: Bool = false
    @Published var error: Bool = false
    @Published var failure: String = ""
}
