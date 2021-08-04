//
//  BLEManager.swift
//  Meshtastic
//
//  Created by Leonid on 01.08.2021.
//

import Foundation
import CoreBluetooth

protocol BLEManagerProtocol: AnyObject {
    func scan(for timeout: Int, onComplite: @escaping ([CBPeripheral]) -> Void)
    func rescan(onComplite: @escaping ([CBPeripheral]) -> Void)
    func connect(device: CBPeripheral, onComplite: @escaping (Bool) -> Void)
    func drop()
}

protocol BLEOpProtocol {
    func listen(enable: Bool, onComplite: @escaping (Result<Bool, Error>) -> Void)
    func write(data: Data, onComplite: @escaping (Result<Bool, Error>) -> Void)
    func read(onComplite: @escaping (Result<Data, Error>) -> Void)
}

enum BLEScanningStatus {
    case initial
    case scanning
    case scanTimeout
    case powerOff
    case userDeny
}

enum BLEDeviceStatus {
    case paired
    case unpaired
}

enum BLEOpStatus {
    case unknown
    case processing
    case done
}

enum BLEError: Error {
    case deviceNotPaired
    case emptyReadValue
    case writeError
    case subscribeError
}

class BLEManager: NSObject {

    static let instance = BLEManager()

    private let meshtasticDeviceServiceUUIDs = [CBUUID(string: "0x6BA1B218-15A8-461F-9FA8-5DCAE273EAFD")]
    private let toRadioUUID = CBUUID(string: "0xF75C76D2-129E-4DAD-A1DD-7866124401E7")
    private let fromRadioUUID = CBUUID(string: "0x8BA2BCC2-EE02-4A55-A531-C525C5E454D5")
    private let numUUID = CBUUID(string: "0xED9DA18C-A800-4F66-A670-AA7547E34453")

    private var toRadioCharacteristic: CBCharacteristic?
    private var fromRadioCharacteristic: CBCharacteristic?
    private var numCharacteristic: CBCharacteristic?

    private lazy var manager: CBCentralManager = { CBCentralManager(delegate: self, queue: nil) }()
    private lazy var discoveredDevices: [CBPeripheral] = { [] }()
    private var linkedDevice: CBPeripheral?
    private var inputData: Result<Data, Error>?
    private var isWriteOpSuccessed: Result<Bool, Error>?
    private var isListenOpSuccessed: Result<Bool, Error>?

    private let scanStatus: Observable<BLEScanningStatus> = { .init(value: .initial) }()
    private let deviceStatus: Observable<BLEDeviceStatus> = { .init(value: .unpaired) }()
    private let readStatus: Observable<BLEOpStatus> = { .init(value: .unknown) }()
    private let writeStatus: Observable<BLEOpStatus?> = { .init(value: .unknown) }()
    private let listenStatus: Observable<BLEOpStatus?> = { .init(value: .unknown) }()

    private override init() {
    }

    // We interested in Meshtastic devices only
    func scanForDevice(timeout: Int = 5) {
        scanStatus.value = .scanning
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(timeout)) {
            self.stopScan()
        }
        manager.scanForPeripherals(withServices: meshtasticDeviceServiceUUIDs, options: nil)
    }

    private func rescanForDevice() {
        discoveredDevices.removeAll()
        manager.stopScan()
        scanForDevice()
    }

    private func stopScan() {
        if manager.isScanning {
            scanStatus.value = .scanTimeout
            manager.stopScan()
        }
    }

    private func connectToDevice(device: CBPeripheral) {
        manager.connect(device, options: nil)
    }

    private func releaseDevice() {
        if let device = linkedDevice {
            manager.cancelPeripheralConnection(device)
            linkedDevice = nil
            deviceStatus.value = .unpaired
        } else {
            log("Noone device is connected")
        }
    }

    private func discoverForService() {
        linkedDevice?.discoverServices(self.meshtasticDeviceServiceUUIDs)
    }

    private func discoverForCharacteristic() {
        if let services = linkedDevice?.services {
            services.forEach { [weak self] service in
                self?.linkedDevice?.discoverCharacteristics(nil, for: service)
            }
        } else {
            log("Failed to start discovering the characteristics, discover the service first")
        }
    }
}

// MARK: BLEManagerProtocol implementation

extension BLEManager: BLEManagerProtocol {
    func drop() {
        self.releaseDevice()
    }

    func connect(device: CBPeripheral, onComplite: @escaping (Bool) -> Void) {
        deviceStatus.binding { [weak linkedDevice] status in
            switch status {
            case .paired:
                onComplite(linkedDevice != nil)
            default:
                break
            }
        }
        self.connectToDevice(device: device)
    }

    func scan(for timeout: Int = 5, onComplite: @escaping ([CBPeripheral]) -> Void) {
        scanStatus.binding { [weak self] status in
            switch status {
            case .scanTimeout:
                onComplite(self?.discoveredDevices ?? [])
            default:
                break
            }
        }
        self.scanForDevice(timeout: timeout)
    }

    func rescan(onComplite: @escaping ([CBPeripheral]) -> Void) {
        scanStatus.binding { [weak self] status in
            switch status {
            case .scanTimeout:
                onComplite(self?.discoveredDevices ?? [])
            default:
                break
            }
        }
        self.rescanForDevice()
    }

}

// MARK: CBCentralManagerDelegate implementation

extension BLEManager: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            scanForDevice()
        case.poweredOff:
            scanStatus.value = .powerOff
        case .unauthorized:
            scanStatus.value = .userDeny
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
        discoverForService()
        log("Device \(peripheral.name ?? "Unknown") linked")
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let err = error {
            linkedDevice = nil
            log("BLE device got err (\(err.localizedDescription)) while disconnecting")
        } else {
            log("Linked device has been released")
            deviceStatus.value = .unpaired
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
        for characteristic in characteristics {
            switch characteristic.uuid {
            case toRadioUUID:
                toRadioCharacteristic = characteristic
            case fromRadioUUID:
                fromRadioCharacteristic = characteristic
            case numUUID:
                numCharacteristic = characteristic
            default:
                break
            }
        }
        deviceStatus.value = .paired
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            inputData = .failure(error)
            return
        }
        guard let value = characteristic.value else {
            inputData = .failure(BLEError.emptyReadValue)
            return
        }
        switch characteristic.uuid {
        case fromRadioUUID:
            inputData = .success(value)
            readStatus.value = .done
        default:
            break
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            isListenOpSuccessed = .failure(error)
            return
        }
        isListenOpSuccessed = .success(true)
        listenStatus.value = .done
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            isWriteOpSuccessed = .failure(error)
            return
        }
        isWriteOpSuccessed = .success(true)
        writeStatus.value = .done
    }
}

// MARK: BLEOpProtocol implementation

extension BLEManager: BLEOpProtocol {

    func listen(enable: Bool, onComplite: @escaping (Result<Bool, Error>) -> Void) {
        if let char = numCharacteristic {
            self.listenStatus.value = .processing
            self.listenStatus.binding { [weak self] state in
                if state == .done {
                    onComplite(self?.isListenOpSuccessed ?? .failure(BLEError.subscribeError))
                }
            }
            self.linkedDevice?.setNotifyValue(enable, for: char)
        } else {
            onComplite(.failure(BLEError.deviceNotPaired))
        }
    }

    func write(data: Data, onComplite: @escaping (Result<Bool, Error>) -> Void) {
        if self.writeStatus.value == .processing { return }
        if let char = toRadioCharacteristic {
            self.writeStatus.value = .processing
            self.writeStatus.binding { [weak self] state in
                if state == .done {
                    onComplite(self?.isWriteOpSuccessed ?? .failure(BLEError.writeError))
                }
            }
            self.linkedDevice?.writeValue(data, for: char, type: .withResponse)
        } else {
            onComplite(.failure(BLEError.deviceNotPaired))
        }
    }

    func read(onComplite: @escaping (Result<Data, Error>) -> Void) {
        if self.readStatus.value == .processing { return }
        if let char = fromRadioCharacteristic {
            self.readStatus.value = .processing
            self.readStatus.binding { [weak self] state in
                if state == .done {
                    onComplite(self?.inputData ?? .failure(BLEError.emptyReadValue))
                }
            }
            self.linkedDevice?.readValue(for: char)
        } else {
            onComplite(.failure(BLEError.deviceNotPaired))
        }
    }
}
