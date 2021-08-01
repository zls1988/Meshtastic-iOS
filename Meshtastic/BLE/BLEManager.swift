//
//  BLEManager.swift
//  Meshtastic
//
//  Created by Leonid on 01.08.2021.
//

import Foundation
import CoreBluetooth

class BLEManager: NSObject {

    private let meshtasticDeviceServiceUUIDs = [CBUUID(string: "0x6BA1B218-15A8-461F-9FA8-5DCAE273EAFD")]
    private let toRadioUUID = CBUUID(string: "0xF75C76D2-129E-4DAD-A1DD-7866124401E7")
    private let fromRadioUUID = CBUUID(string: "0x8BA2BCC2-EE02-4A55-A531-C525C5E454D5")
    private let numUUID = CBUUID(string: "0xED9DA18C-A800-4F66-A670-AA7547E34453")
    private let scanTimeOut = 5

    private lazy var manager: CBCentralManager = { CBCentralManager(delegate: self, queue: nil) }()
    private lazy var discoveredDevices: [CBPeripheral] = { [] }()
    private var linkedDevice: CBPeripheral?

    // We interested in Meshtastic devices only
    func scanForDevice() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(scanTimeOut)) { [weak self] in
            self?.stopScan()
        }
        manager.scanForPeripherals(withServices: meshtasticDeviceServiceUUIDs, options: nil)
    }

    func rescanForDevice() {
        discoveredDevices.removeAll()
        manager.stopScan()
        scanForDevice()
    }

    func stopScan() {
        if manager.isScanning {
            manager.stopScan()
        }
    }

    func connectToDevice(device: CBPeripheral) {
        manager.connect(device, options: nil)
    }

    func releaseDevice() {
        if let device = linkedDevice {
            manager.cancelPeripheralConnection(device)
            linkedDevice = nil
        } else {
            log("Noone device is connected")
        }
    }

    func discoverForService() {
        linkedDevice?.discoverServices(self.meshtasticDeviceServiceUUIDs)
    }

    func discoverForCharacteristic() {
        if let services = linkedDevice?.services {
            services.forEach { [weak self] service in
                self?.linkedDevice?.discoverCharacteristics(nil, for: service)
            }
        } else {
            log("Failed to start discovering the characteristics, discover the service first")
        }
    }
}

// MARK: CBCentralManagerDelegate implementation

extension BLEManager: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            scanForDevice()
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

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        log("Device \(peripheral.name ?? "Unknown") has found (rssi: \(RSSI))")
        discoveredDevices.append(peripheral)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        linkedDevice = peripheral
        log("Device \(peripheral.name ?? "Unknown") linked")
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let err = error {
            linkedDevice = nil
            log("BLE device got err (\(err.localizedDescription)) while disconnecting")
        } else {
            log("Linked device has been released")
        }
    }
}

// MARK: CBPeripheralDelegate implementation

extension BLEManager: CBPeripheralDelegate {

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let err = error {
            log("Service discovering failed with error = \(err.localizedDescription)")
        } else {
            // We know that services have been discovered at this point
            discoverForCharacteristic()
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            log("No one characteristics have been discovered on \(service.uuid)")
            return
        }

        characteristics.forEach { characteristic in
            switch characteristic.uuid {
            case toRadioUUID:
                break
            case fromRadioUUID:
                break
            case numUUID:
                break
            default:
                break
            }
        }
    }
}
