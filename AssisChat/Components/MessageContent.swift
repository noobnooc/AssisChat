//
//  MessageContent.swift
//  AssisChat
//
//  Created by Nooc on 2023-04-04.
//

import SwiftUI
import MarkdownUI
import Splash

struct MessageContent: View {
    @Environment(\.colorScheme) private var colorScheme

    @EnvironmentObject private var settingsFeature: SettingsFeature

    let content: String

    var body: some View {
        Markdown(content.trimmingCharacters(in: .whitespacesAndNewlines))
            .markdownTextStyle(textStyle: {
                FontSize(CGFloat(settingsFeature.selectedFontSize.size))
            })
            .markdownTextStyle(\.link, textStyle: {
                UnderlineStyle(.single)
                ForegroundColor(.primary.opacity(0.8))
            })
            .markdownBlockStyle(\.codeBlock) { configuration in
                ScrollView(.horizontal) {
                    configuration.label
                        .padding(10)
                }
                .markdownTextStyle(textStyle: {
                    FontFamilyVariant(.monospaced)
                    FontSize(.em(0.85))
                })
                .background(Color.primary.opacity(0.05))
                .cornerRadius(8)
                .padding(.bottom)
                .textSelection(.enabled)
                //                                TODO: - Get the content
                //                                .overlay(alignment: .bottomTrailing) {
                //                                    Button {
                //
                //                                    } label: {
                //                                        Image(systemName: "doc.on.doc")
                //                                    }
                //                                    .tint(.secondary)
                //                                    .frame(height: 25)
                //                                    .buttonStyle(.borderedProminent)
                //                                    .padding(10)
                //                                }
            }
            .markdownCodeSyntaxHighlighter(
                .splash(theme: colorScheme == .dark ? .wwdc17(withFont: .init(size: 16)) : .sunset(withFont: .init(size: 16)))
            )
    }
}
struct MessageContent_Previews: PreviewProvider {
    static var previews: some View {
        MessageContent(content: "Hello")
    }
}
