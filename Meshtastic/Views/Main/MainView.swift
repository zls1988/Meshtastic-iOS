//
//  MainView.swift
//  Meshtastic
//
//  Created by lzamaraev on 14.08.2021.
//

import SwiftUI

struct MainView: View {
    @StateObject var vm = MainViewModel()

    var body: some View {
        BaseView<DefaultProgress, DefaultError, MainViewContent>(isLoading: $vm.loading, isError: $vm.error,
                                                              progress: { DefaultProgress() },
                                                              failure: { DefaultError(failure: $vm.failure) },
                                                              content: { MainViewContent(vm: vm) })
    }
}

struct MainViewContent: View {
    @ObservedObject var vm: MainViewModel

    @ViewBuilder
    var body: some View {
        if vm.isDeviceConnected {
            AppView()
        } else {
            WizardView()
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
