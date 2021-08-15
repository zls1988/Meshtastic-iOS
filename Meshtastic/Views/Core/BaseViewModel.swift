//
//  BaseViewModel.swift
//  Meshtastic
//
//  Created by lzamaraev on 14.08.2021.
//

import Foundation

class BaseViewModel: ObservableObject {

    @Published var loading: Bool = false
    @Published var error: Bool = false
    @Published var failure: String = ""
}
