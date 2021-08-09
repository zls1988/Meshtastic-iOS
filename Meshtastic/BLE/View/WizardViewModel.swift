//
//  WizardViewModel.swift
//  Meshtastic
//
//  Created by lzamaraev on 09.08.2021.
//

import Foundation

class WizardViewModel: BaseViewModel {

    let bleManager: BLEManagerProtocol = BLEManager.shared
}

class BaseViewModel: ObservableObject {

    @Published var loading: Bool = false
    @Published var error: Bool = false
}
