//
//  MConnector.swift
//  M-iOS_test
//
//  Created by Evgeny Yagrushkin on 2020-10-13.
//

import Foundation
import SwiftProtobuf
import CoreBluetooth

protocol MConnectorProtocol: AnyObject {
    func startConfig(peripheral: CBPeripheral)
    func didReceive(peripheral: CBPeripheral, data: Data, characteristic: String)
    var bleManager: MeshtasticBlueConnecting {get set}
}

class MConnector: MConnectorProtocol {

    enum Characteristics: String {
        case fromRadio = "8ba2bcc2-ee02-4a55-a531-c525c5e454d5" // read
        case toradio = "f75c76d2-129e-4dad-a1dd-7866124401e7"   // write
        case fromnum = "ed9da18c-a800-4f66-a670-aa7547e34453"   // read,notify,write
    }

    struct Chars {
        static let meshtasticServiceUUID = "6ba1b218-15a8-461f-9fa8-5dcae273eafd"
        static let fromRadioCharacteristicUUID = "8ba2bcc2-ee02-4a55-a531-c525c5e454d5".uppercased() // read
        static let toRadioCharacteristicUUID = "f75c76d2-129e-4dad-a1dd-7866124401e7".uppercased() // write
        static let fromNumCharacteristicUUID = "ed9da18c-a800-4f66-a670-aa7547e34453".uppercased() // read,notify,write
        static let GATTUUIDSwVersionString = "2a28".uppercased() // read,notify,write
        static let GATTUUIDManuName = "2a29".uppercased() // read,notify,write
        static let GATTUUIDHwVersionStr = "2a27".uppercased() // read,notify,write
    }

    var bleManager: MeshtasticBlueConnecting
    var myInfo: MyNodeInfo?
    var radioConfig: RadioConfig?
    var nodeInfo: NodeInfo?

    init(bleManager: MeshtasticBlueConnecting) {
        self.bleManager = bleManager
    }

    func startConfig(peripheral: CBPeripheral) {
        // read data from the from radio
        var toRadio = ToRadio()
        toRadio.wantConfigID = 0
        let data = try? toRadio.serializedData()
        bleManager.peripheralWrite(peripheral: peripheral, data: data, characteristicID: Chars.toRadioCharacteristicUUID)
        bleManager.readValue(from: peripheral, characteristicID: Chars.fromRadioCharacteristicUUID)
    }

    func readFromRadio(peripheral: CBPeripheral) {
        bleManager.readValue(from: peripheral, characteristicID: Chars.fromRadioCharacteristicUUID)
    }

    func getAllNodeInfo(peripheral: CBPeripheral) {
        let packet = NodeInfo()
        let packetData = try? packet.serializedData()
        bleManager.peripheralWrite(peripheral: peripheral, data: packetData, characteristicID: Chars.toRadioCharacteristicUUID)
    }

    func didReceive(peripheral: CBPeripheral, data: Data, characteristic: String) {
        debugLog("didReceive char", space: .mesh)

        switch characteristic {
        case Chars.fromRadioCharacteristicUUID:
            if data.count != 0 {
                do {
                    let fromRadio = try FromRadio(serializedData: data)
                    bleManager.readValue(from: peripheral, characteristicID: Chars.fromRadioCharacteristicUUID)

                    switch fromRadio.payloadVariant {
                    case .radio(let value):
                        debugLog("radioConfig:\n    \(value.debugDescription)", space: .mesh)

                    case .myInfo(let value):
                        debugLog("my_info:\n    \(value.debugDescription)", space: .mesh)

                    case .nodeInfo(let value):
                        nodeInfo = value
                        debugLog("node_info:\n  \(value.debugDescription)", space: .mesh)

                    default:
                        debugLog("another data:\n   \(fromRadio)", space: .mesh)
                    }
                } catch let error {
                    debugLog(error.localizedDescription, level: .error, space: .mesh)
                }
            } else {
                debugLog("data is empty \(Chars.fromRadioCharacteristicUUID)", level: .error, space: .mesh)
            }

        case Chars.fromNumCharacteristicUUID:
            readFromRadio(peripheral: peripheral)
//            if let fromRadio = try? FromRadio(serializedData: data) {
//                print(fromRadio)
//            }

        default:
            break
        }

    }

}
