//
//  WizardSwiftUIView.swift
//  Meshtastic
//
//  Created by lzamaraev on 04.08.2021.
//

import SwiftUI
import CoreBluetooth

struct WizardView: View {
    @StateObject var vm = WizardViewModel()

    var body: some View {
        BaseView<WizardProgress, DefaultError, WizardContent>(isLoading: $vm.loading, isError: $vm.error,
                                                     progress: { WizardProgress() },
                                                     failure: { DefaultError(failure: $vm.failure) },
                                                     content: { WizardContent(vm: vm) })
    }
}

struct WizardContent: View {
    @ObservedObject var vm: WizardViewModel

    var body: some View {
        ZStack {
            if vm.devices.isEmpty {
                PromtToScanDevicesView {
                    vm.scanForDevices()
                }
            } else {
                DeviceListView(devices: vm.devices.enumerated().map({ (_, device) in
                    DeviceElement(uuid: "\(device.identifier)", description: "\(device.name ?? "UNKNOWN")")
                })) { device in
                    vm.connect(device: device.uuid)
                } rescanClick: {
                    vm.rescan()
                }

            }
        }
    }
}

struct WizardProgress: View {
    var body: some View {
        ProgressView("Scanning...")
    }
}

struct DeviceElementView: View {
    let device: DeviceElement

    var body: some View {
        HStack {
            Image("main.maps")
            VStack(alignment: .leading, spacing: 0) {
                Text(device.uuid).font(.caption).lineLimit(1)
                Text(device.description).font(.body).lineLimit(1)
            }

        }
    }
}

struct DeviceListView: View {
    let devices: [DeviceElement]
    let onClick: (DeviceElement) -> Void
    let rescanClick: () -> Void

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Devices list")) {
                    ForEach(devices, id: \.self.uuid) { item in
                        DeviceElementView(device: item).onTapGesture(perform: {
                            onClick(item)
                        })
                    }
                }
            }
            .navigationTitle("Founded devices")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button() {
                        rescanClick()
                    } label: {
                        Image(systemName: "dot.radiowaves.left.and.right")
                    }
                }
            }
        }

    }
}

struct PromtToScanDevicesView: View {
    var onButtonClick: () -> Void

    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Text("Run scanner")
            Button() {
                onButtonClick()
            } label: {
                Image(systemName: "dot.radiowaves.left.and.right")
                .resizable()
                .frame(width: 32, height: 28)
            }
        }
    }
}

struct WizardSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DeviceElementView(device: DeviceElement(uuid: "EB4F724D-DA05-7A86-F21F-7BA6FD64A7A2", description: "Description test"))
                .previewLayout(.fixed(width: 300, height: 100))
            PromtToScanDevicesView {
                log("Scanner runned...")
            }.previewLayout(.fixed(width: 300, height: 100))
            DeviceListView(devices: [
                DeviceElement(uuid: "EB4F724D-DA05-7A86-F21F-7BA6FD64A7A1", description: "Description test"),
                DeviceElement(uuid: "EB4F724D-DA05-7A86-F21F-7BA6FD64A7A2", description: "Description test"),
                DeviceElement(uuid: "EB4F724D-DA05-7A86-F21F-7BA6FD64A7A3", description: "Description test"),
                DeviceElement(uuid: "EB4F724D-DA05-7A86-F21F-7BA6FD64A7A4", description: "Description test")
            ]) { device in
                log("\(device.id)")
            } rescanClick: {
                log("Rescan clicked")
            }
                .previewLayout(.fixed(width: 300, height: 400))
            WizardView()
        }
    }
}
