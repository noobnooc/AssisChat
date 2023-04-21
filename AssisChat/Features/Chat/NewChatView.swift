//
//  ChatTemplateSelectView.swift
//  AssisChat
//
//  Created by Nooc on 2023-03-09.
//

import SwiftUI

struct NewChatView: View {
    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject private var settingsFeature: SettingsFeature
    @EnvironmentObject private var chatFeature: ChatFeature

    var body: some View {
        List {
            Section("CHAT_CUSTOM") {
                NavigationLink {
                    CustomNewChatView() {
                        dismiss()
                    }
                } label: {
                    PresetItem(preset: PlainChat(name: String(localized: "NEW_CHAT_NAME"), temperature: .balanced, systemMessage: String(localized: "NEW_CHAT_NAME"), historyLengthToSend: .defaultHistoryLengthToSend, messagePrefix: nil, autoCopy: false, icon: .default, color: .default, model: Chat.OpenAIModel.default.rawValue))
                }
            }

            Section("CHAT_PRESETS") {
                ForEach(ChatPreset.presets, id: \.name) { preset in
                    PresetItem(preset: preset)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            dismiss()
                            chatFeature.createChat(preset, forModel: settingsFeature.orderedAdapters.first?.defaultModel)
                        }
                }
            }
        }
    }
}

private struct PresetItem: View {
    let preset: PlainChat

    var body: some View {
        HStack {
            preset.icon.image
                .font(.title2)
                .frame(width: 24, height: 24)
#if os(iOS)
                .padding(13)
#else
                .padding(10)
#endif
                .background(preset.color?.color)
                .cornerRadius(8)
                .colorScheme(.dark)

            VStack(alignment: .leading, spacing: 5) {
                Text(preset.name)
                Text(preset.systemMessage ?? "")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
    }
}

struct ChatTemplateSelectView_Previews: PreviewProvider {
    static var previews: some View {
        NewChatView()
    }
}
