//
//  MainViewModel.swift
//  Meshtastic
//
//  Created by lzamaraev on 14.08.2021.
//

import Foundation

class MainViewModel: BaseViewModel {
    private let manager: DeviceConnectionProtocol = BLEManager.shared

    @Published var isDeviceConnected: Bool

    override init() {
        isDeviceConnected = manager.isDeviceConnected()
        super.init()
        self.subscribe()
    }

    private func subscribe() {
        manager.subscribe { [weak self] state in
            switch state {
            case .paired:
                self?.isDeviceConnected = true
            default:
                self?.isDeviceConnected = false
            }
        }
    }
}
