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
}

class BaseViewModel: ObservableObject {

    @Published var loading: Bool = false
    @Published var error: Bool = false
}
