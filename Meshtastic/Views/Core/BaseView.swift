//
//  BaseView.swift
//  Meshtastic
//
//  Created by lzamaraev on 10.08.2021.
//

import SwiftUI

struct BaseView<Progress, Error, Content>: View where
    Progress: View, Error: View, Content: View {

    @Binding var isLoading: Bool
    @Binding var isError: Bool

    let progress: () -> Progress
    let failure: () -> Error
    let content: () -> Content

    var body: some View {
        ZStack {
            if isLoading {
                progress()
            }
            if isError {
                failure()
            }
            if !isError && !isLoading {
                content()
            }
        }
    }
}

struct DefaultProgress: View {
    var body: some View {
        ProgressView("Loading...")
    }
}

struct DefaultError: View {
    @Binding var failure: String

    var body: some View {
        Text("Error occured with \(failure)")
    }
}

struct Content: View {
    var body: some View {
        Text("Main content")
    }
}

struct BaseView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BaseView<DefaultProgress, DefaultError, Content>(isLoading: .constant(true), isError: .constant(false),
                                                         progress: { DefaultProgress() },
                                                         failure: { DefaultError(failure: .constant("")) },
                                                         content: { Content() })
            BaseView<DefaultProgress, DefaultError, Content>(isLoading: .constant(false), isError: .constant(true),
                                                         progress: { DefaultProgress() },
                                                         failure: { DefaultError(failure: .constant(BLEError.deviceNotPaired.localizedDescription)) },
                                                         content: { Content() })
            BaseView<DefaultProgress, DefaultError, Content>(isLoading: .constant(false), isError: .constant(false),
                                                         progress: { DefaultProgress() },
                                                         failure: { DefaultError(failure: .constant("")) },
                                                         content: { Content() })
        }
    }
}
