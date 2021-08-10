//
//  RadioInterface.swift
//  Meshtastic
//
//  Created by lzamaraev on 05.08.2021.
//

import Foundation

protocol MeshtasticProtocol {
    func sendMessage(message: String, to user: String?)
    func setOwner(owner user: User)
    func setChannelSetting(settings channel: ChannelSettings)
}

class RadioInterface {

    private let opTimeout: UInt32 = 1
    private let bleOperator: BLEOpProtocol = BLEManager.shared
    private let readingQueue: DispatchQueue = DispatchQueue(label: "ru.itrequest.meshtastic.RadioInterface.readingQueue")
    private let writingQueue: DispatchQueue = DispatchQueue(label: "ru.itrequest.meshtastic.RadioInterface.writingQueue")

    private func send(data: Data, onComplite: @escaping (Result<Bool, Error>) -> Void) {
        writingQueue.async {
            self.bleOperator.write(data: data) { result in
                switch result {
                case .success(let success):
                    onComplite(.success(success))
                case .failure(let error):
                    log(error)
                    if let isWrittingError = error as? BLEError {
                        if isWrittingError == .writeError {
                            sleep(self.opTimeout)
                            self.send(data: data, onComplite: onComplite)
                        } else {
                            onComplite(.failure(error))
                        }
                    } else {
                        onComplite(.failure(error))
                    }
                }
            }
        }
    }

    private func read(onComplite: @escaping (Result<Data, Error>) -> Void) {
        writingQueue.async {
            self.bleOperator.read { result in
                switch result {
                case .success(let data):
                    onComplite(.success(data))
                case .failure(let error):
                    log(error)
                    if let isWrittingError = error as? BLEError {
                        if isWrittingError == .writeError {
                            sleep(self.opTimeout)
                            self.read(onComplite: onComplite)
                        } else {
                            onComplite(.failure(error))
                        }
                    } else {
                        onComplite(.failure(error))
                    }
                }
            }
        }
    }
}
