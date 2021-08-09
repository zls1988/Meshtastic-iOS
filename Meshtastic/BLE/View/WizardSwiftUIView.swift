//
//  WizardSwiftUIView.swift
//  Meshtastic
//
//  Created by lzamaraev on 04.08.2021.
//

import SwiftUI

struct WizardSwiftUIView: View {
    @StateObject var vm = WizardViewModel()

    var body: some View {
        BaseView(isLoading: $vm.loading, isError: $vm.error) {
            ZStack {
                if vm.devices.isEmpty {
                    Text("TEST")
                } else {
                    Text("Run device scanning...").onTapGesture(perform: {
                            vm.scanForDevices()
                    })
                }
            }
        }
    }
}

struct WizardSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DeviceElementView(device: DeviceData(id: 0, uuid: "UUID", description: "Description test"))
                .previewLayout(.fixed(width: 300, height: 100))
            DeviceListView(devices: [
                DeviceData(id: 1, uuid: "UUID-1", description: "Description test"),
                DeviceData(id: 2, uuid: "UUID-2", description: "Description test"),
                DeviceData(id: 3, uuid: "UUID-3", description: "Description test"),
                DeviceData(id: 4, uuid: "UUID-4", description: "Description test")
            ]) { device in
                debugLog("\(device.id)")
            }
                .previewLayout(.fixed(width: 500, height: 400))
            WizardSwiftUIView()
        }
    }
}

struct DeviceElementView: View {
    let device: DeviceData

    var body: some View {

        HStack {
            Image("main.maps")
            Text(device.uuid)
            Text(device.description)
        }
    }
}

struct BaseView<Content>: View where Content: View {
    @Binding var isLoading: Bool
    @Binding var isError: Bool

    var content: () -> Content

    var body: some View {
        if isLoading {
            ProgressView("Scanning…")
        }
        if isError {
            Text("ERROR")
        }
        if !isError && !isLoading {
            content()
        }
    }
}

struct DeviceListView: View {
    let devices: [DeviceData]
    let onClick: (DeviceData) -> Void

    var body: some View {
        List(devices, id: \.id) { device in
            DeviceElementView(device: device).onTapGesture(perform: {
                onClick(device)
            })
        }
    }
}

struct DeviceData: Identifiable, Hashable {
    var id: Int
    let uuid: String
    let description: String
}
