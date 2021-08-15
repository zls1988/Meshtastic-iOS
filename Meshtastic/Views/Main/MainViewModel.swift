//
//  MainViewModel.swift
//  Meshtastic
//
//  Created by lzamaraev on 14.08.2021.
//

import Foundation

class MainViewModel: BaseViewModel {
    private let status: DeviceConnectionProtocol

    @Published var isDeviceConnected: Bool

    override init() {
        status = BLEManager.shared
        isDeviceConnected = status.isDeviceConnected()
        super.init()
    }
}
