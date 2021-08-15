//
//  DeviceElement.swift
//  Meshtastic
//
//  Created by lzamaraev on 14.08.2021.
//

import Foundation

struct DeviceElement: Hashable {
    let uuid: String
    let description: String
}

extension DeviceElement: Identifiable {
    var id: String {
        self.uuid
    }
}
