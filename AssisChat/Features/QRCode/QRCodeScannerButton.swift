//
//  QRCodeScannerButton.swift
//  AssisChat
//
//  Created by Nooc on 2023-04-27.
//

#if os(iOS)
import SwiftUI
import CodeScanner

struct QRCodeScannerButton: View {
    @EnvironmentObject private var settingsFeature: SettingsFeature

    @State private var scanning = false

    var body: some View {
        Button {
            scanning = true
        } label: {
            Label("Scan QRCode", systemImage: "qrcode.viewfinder")
        }
        .sheet(isPresented: $scanning) {
            QRCodeScanningView()
                .environmentObject(QRCodeFeature(settingsFeature: settingsFeature))
        }
    }
}

struct QRCodeScannerButton_Previews: PreviewProvider {
    static var previews: some View {
        QRCodeScannerButton()
    }
}
#endif
