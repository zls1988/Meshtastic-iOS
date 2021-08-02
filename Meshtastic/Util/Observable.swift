//
//  Observable.swift
//  Meshtastic
//
//  Created by lzamaraev on 02.08.2021.
//

import Foundation

class Observable<T> {
    typealias Listener = (T) -> Void

    var value: T {
        didSet {
            listener?(value)
        }
    }

    private var listener: Listener?

    init(value: T) {
        self.value = value
    }

    func binding(fire asBinded: Bool = false, listener: @escaping Listener) {
        self.listener = listener
        if asBinded {
            self.listener?(value)
        }
    }
}
