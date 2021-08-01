//
//  BLEManager.swift
//  Meshtastic
//
//  Created by Leonid on 01.08.2021.
//

import Foundation
import CoreBluetooth

class BLEManager: NSObject {

    private let serviceUUID = CBUUID(string: "0x6BA1B218-15A8-461F-9FA8-5DCAE273EAFD")
    private let toRadioUUID = CBUUID(string: "0xF75C76D2-129E-4DAD-A1DD-7866124401E7")
    private let fromRadioUUID = CBUUID(string: "0x8BA2BCC2-EE02-4A55-A531-C525C5E454D5")
    private let numUUID = CBUUID(string: "0xED9DA18C-A800-4F66-A670-AA7547E34453")

    private var manager: CBCentralManager!

    override init() {
        super.init()
        self.manager = CBCentralManager(delegate: self, queue: nil)
    }
}

// MARK: CBCentralManagerDelegate implementation

extension BLEManager: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            // TODO: Implement connection
            log("BT poweredOn")
        case.poweredOff:
            // TODO: User has disabled Bluetooth
            log("BT poweredOff")
        case .unauthorized:
            // TODO: User has refused permission, disable app
            log("BT unauthorized")
        case .resetting:
            log("BT resetting")
        case .unsupported:
            fatalError("Your device doesn't support Bluetooth")
        case.unknown:
            // Do nothing
            log("BT unknown")
        @unknown default:
            fatalError("Unknown the Bluetooth state")
        }
    }
}
