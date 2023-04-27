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
                FontSize(settingsFeature.selectedFontSize.value)
            })
            .markdownTextStyle(\.link, textStyle: {
                UnderlineStyle(.single)
                ForegroundColor(.primary.opacity(0.8))
            })
            .markdownBlockStyle(\.codeBlock) { configuration in
                ScrollView(.horizontal) {
                    configuration.label
                        .padding(10)
                        .padding(.trailing, 20)
                }
                .markdownTextStyle(textStyle: {
                    FontFamilyVariant(.monospaced)
                    FontSize(.em(0.85))
                })
                #if os(iOS)
                .background(Color.tertiaryBackground)
                #else
                .background(Color.background.opacity(0.4))
                #endif
                .cornerRadius(8)
                .padding(.bottom)
                .overlay(alignment: .topTrailing) {
                    Button {
                        Clipboard.copyToClipboard(text: configuration.content)
                    } label: {
                        Image(systemName: "doc.on.doc")
                    }
                    .padding(10)
                }
            }
            .markdownCodeSyntaxHighlighter(
                .splash(theme: colorScheme == .dark ? .wwdc17(withFont: .init(size: 16)) : .sunset(withFont: .init(size: 16)))
            )
            .textSelection(.enabled)
    }
}
struct MessageContent_Previews: PreviewProvider {
    static var previews: some View {
        MessageContent(content: "Hello")
    }
}
