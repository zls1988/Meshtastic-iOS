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

    func connect(device uuid: String) {
        loading = true
        bleManager.connect(device: uuid) { result in
            self.loading = false
            if result {
                log("Connected to \(uuid)")
            } else {
                self.failure = "Connection to \(uuid) failed, try again."
                self.error = true
            }
        }
    }
}
