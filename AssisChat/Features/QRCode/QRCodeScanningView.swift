//
//  QRCodeScanningView.swift
//  AssisChat
//
//  Created by Nooc on 2023-04-27.
//

import SwiftUI
#if os(iOS)
import CodeScanner
#endif

struct QRCodeScanningView: View {
    @EnvironmentObject private var qrCodeFeature: QRCodeFeature

    @State var handlerResult: QRCodeFeature.HandlerResult?
    @State var handling = false

    var prompt: String? {
        guard let result = handlerResult else { return nil }

        switch result {
        case .success(let type):
            switch type {
            case .config: return String(localized: "Config success", comment: "Config success with QRCode")
            }
        case .error(let error):
            switch error {
            case .configFailed: return String(localized: "Failed to config", comment: "Failed to config with QRCode")
            case .invalidParams: return String(localized: "Invalid params", comment: "QRCode params are invalid")
            case .unidentified: return String(localized: "Unidentified QRCode", comment: "Unidentified QRCode hint")
            case .unrecognized: return String(localized: "Unrecognized QRCode", comment: "Unrecognized QRCode hint")
            }
        }
    }

    var body: some View {
        VStack {
            GeometryReader { geometry in
                let maxHeight = geometry.size.height - 40
                let maxWidth = geometry.size.width - 40
                let edgeLength = min(maxHeight, maxWidth)

                VStack {
                    ZStack {
#if os(iOS)
                        CodeScannerView(codeTypes: [.qr], scanMode: .once, manualSelect: true, showViewfinder: true) { response in
                            switch response {
                            case .success(let result):
                                Task {
                                    await handContent(content: result.string)
                                }
                            case .failure(let error):
                                print("####### \(error.localizedDescription)")
                            }
                        }
#endif
                    }
                    .frame(width: edgeLength, height: edgeLength)
                    .cornerRadius(25)
                    .padding(20)
                    .overlay {
                        if handling || handlerResult != nil {
                            ZStack {
                                Rectangle()
                                    .fill(Color.black.opacity(0.9))

                                VStack {
                                    if case .success = handlerResult {
                                        Image(systemName: "checkmark.circle")
                                            .font(.largeTitle)
                                            .foregroundColor(.appGreen)
                                    } else if case .error = handlerResult {
                                        Image(systemName: "xmark.octagon")
                                            .font(.largeTitle)
                                            .foregroundColor(.appRed)
                                    } else {
                                        UniformProgressView()
                                    }

                                    Text(prompt ?? "")
                                        .padding(.top)
                                }
                                .colorScheme(.dark)
                            }
                            .frame(width: edgeLength, height: edgeLength)
                            .cornerRadius(25)
                        }
                    }
                    .padding(.top, 50)

                    VStack {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "gearshape.2")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.accentColor)

                                Text("Import configuration")
                            }

                            HStack {
                                Image(systemName: "wand.and.stars")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.accentColor)

                                Text("Import chat prompts")
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.secondaryGroupedBackground)
                    .cornerRadius(25)
                    .padding(20)
                    .animation(.default, value: handling)
                    .animation(.default, value: handlerResult != nil)
                }
            }
        }
        .background(Color.groupedBackground)
    }

    private func handContent(content: String) async {
        print("###### \(content)")
        handling = true
        handlerResult = await qrCodeFeature.handleString(content: content)
        Haptics.veryLight()
        handling = false
    }
}

struct QRCodeScanningView_Previews: PreviewProvider {
    static var previews: some View {
        QRCodeScanningView()
    }
}
