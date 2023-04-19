//
//  ChatEditor.swift
//  AssisChat
//
//  Created by Nooc on 2023-03-07.
//

import SwiftUI

class ChatEditorModel: ObservableObject {
    @Published var name: String
    @Published var temperature: Chat.Temperature
    @Published var systemMessage: String
    @Published var historyLengthToSend: Int16
    @Published var messagePrefix: String
    @Published var autoCopy: Bool
    @Published var icon: Chat.Icon
    @Published var color: Chat.Color?
    @Published var model: String

    init(
        name: String,
        temperature: Chat.Temperature,
        systemMessage: String,
        historyLengthToSend: Int16,
        messagePrefix: String,
        autoCopy: Bool,
        icon: Chat.Icon,
        color: Chat.Color?,
        model: String
    ) {
        self.name = name
        self.temperature = temperature
        self.systemMessage = systemMessage
        self.historyLengthToSend = historyLengthToSend
        self.messagePrefix = messagePrefix
        self.autoCopy = autoCopy
        self.icon = icon
        self.color = color
        self.model = model
    }

    init(chat: Chat) {
        self.name = chat.name
        self.temperature = chat.temperature
        self.systemMessage = chat.systemMessage ?? ""
        self.historyLengthToSend = chat.storedHistoryLengthToSend
        self.messagePrefix = chat.messagePrefix ?? ""
        self.autoCopy = chat.autoCopy
        self.icon = chat.icon
        self.color = chat.color
        self.model = chat.rawModel ?? Chat.OpenAIModel.default.rawValue
    }

    var plain: PlainChat {
        PlainChat(
            name: name.isEmpty ? String(localized: "NEW_CHAT_NAME") : name,
            temperature: temperature,
            systemMessage: systemMessage.count > 0 ? systemMessage : nil,
            historyLengthToSend: historyLengthToSend,
            messagePrefix: messagePrefix.count > 0 ? messagePrefix : nil,
            autoCopy: autoCopy,
            icon: icon,
            color: color,
            model: model
        )
    }

    var available: Bool {
        plain.available
    }
}

struct ChatEditor<Actions: View>: View {
    @EnvironmentObject private var settingsFeature: SettingsFeature

    @ObservedObject var model: ChatEditorModel

    let actions: Actions

    init(model: ChatEditorModel, @ViewBuilder actions: () -> Actions) {
        self.model = model
        self.actions = actions()
    }

    var body: some View {
        List {
            Section("CHAT_EDITOR_CHAT_SECTION") {
                HStack(spacing: 0) {
                    IconSelectorButton(selection: $model.icon)
                        .padding()
                        .background(model.color?.color ?? Chat.Color.default.color)
                        .foregroundColor(Color.secondaryGroupedBackground)
                        .cornerRadius(10)

                    TextField("NEW_CHAT_NAME", text: $model.name)
                        .font(.title3)
                        .padding()
                    #if os(macOS)
                        .textFieldStyle(.roundedBorder)
                    #endif
                }

                ColorSelector(selection: $model.color)
                    .padding(.vertical, 5)
                #if os(macOS)
                    .padding(.horizontal, 5)
                #endif
            }

            Section("CHAT_EDITOR_CONFIG_SECTION") {
                Picker("CHAT_TEMPERATURE", selection: $model.temperature) {
                    Text(Chat.Temperature.creative.display)
                        .tag(Chat.Temperature.creative)

                    Text(Chat.Temperature.balanced.display)
                        .tag(Chat.Temperature.balanced)

                    Text(Chat.Temperature.precise.display)
                        .tag(Chat.Temperature.precise)
                }

                Picker("CHAT_OPENAI_MODEL", selection: $model.model) {
                    ForEach(settingsFeature.activeModels, id: \.self) { model in
                        Text(model)
                            .tag(model)
                    }
                }

                VStack(alignment: .leading) {
                    Text("CHAT_ROLE_PROMPT")
                        .font(.footnote)
                        .foregroundColor(Color.secondary)

                    if #available(iOS 16, macOS 13, *) {
                        TextField("CHAT_ROLE_PROMPT_HINT", text: $model.systemMessage, axis: .vertical)
                            .lineLimit(1...3)
#if os(macOS)
                            .textFieldStyle(.roundedBorder)
#endif
                    } else {
                        TextField("CHAT_ROLE_PROMPT_HINT", text: $model.systemMessage)
#if os(macOS)
                            .textFieldStyle(.roundedBorder)
#endif
                    }
                }
                .frame(maxWidth: .infinity)

                VStack(alignment: .leading) {
                    HStack {
                        Text("CHAT_MESSAGE_PREFIX")
                            .font(.footnote)
                            .foregroundColor(Color.secondary)
                        ProBadge()
                    }

                    if #available(iOS 16, macOS 13, *) {
                        TextField("CHAT_MESSAGE_PREFIX_HINT", text: $model.messagePrefix, axis: .vertical)
                            .lineLimit(1...3)
#if os(macOS)
                            .textFieldStyle(.roundedBorder)
#endif
                    } else {
                        TextField("CHAT_MESSAGE_PREFIX_HINT", text: $model.messagePrefix)
#if os(macOS)
                            .textFieldStyle(.roundedBorder)
#endif
                    }
                }
                .frame(maxWidth: .infinity)

                VStack(alignment: .trailing) {
                    Picker("CHAT_HISTORY_LENGTH_TO_SEND", selection: $model.historyLengthToSend) {
                        Text("CHAT_HISTORY_LENGTH_TO_SEND_MAX")
                            .tag(Int16.historyLengthToSendMax)
                        Text(String("50"))
                            .tag(Int16(50))
                        Text(String("20"))
                            .tag(Int16(20))
                        Text(String("10"))
                            .tag(Int16(10))
                        Text(String("4"))
                            .tag(Int16(4))
                        Text("CAHT_HISTORY_LENGTH_TO_SEND_NONE")
                            .tag(Int16.zero)
                    }

                    Text("CHAT_HISTORY_LENGTH_TO_SEND_HINT")
                        .font(.footnote)
                        .foregroundColor(Color.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)

                VStack(alignment: .trailing) {
                    Toggle(isOn: $model.autoCopy) {
                        HStack {
                            Text("CHAT_AUTO_COPY")
                            ProBadge()
                        }
                    }

                    Text("CHAT_AUTO_COPY_HINT")
                        .font(.footnote)
                        .foregroundColor(Color.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }

            actions
        }
#if os(macOS)
        .listStyle(.inset)
#endif
    }

    // MARK: - IconSelectorButton
    private struct IconSelectorButton: View {
        @Binding var selection: Chat.Icon

        @State var sheetPresented = false

        var body: some View {
            Button {
                sheetPresented = true
            } label: {
                selection.image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
            .sheet(isPresented: $sheetPresented) {
#if os(iOS)
                NavigationView {
                    ChatIconSelector(selection: $selection)
                        .navigationTitle("CHAT_EDITOR_ICON_SELECTOR_TITLE")
                        .inlineNavigationBar()
                        .navigationBarItems(trailing: Button("DONE", action: {
                            sheetPresented = false
                        }))
                        .foregroundColor(.primary)
                }
                .navigationViewStyle(.stack)
#else
                ChatIconSelector(selection: $selection)
                    .navigationTitle("CHAT_EDITOR_ICON_SELECTOR_TITLE")
                    .frame(width: 500, height: 500)
                    .inlineNavigationBar()
                    .foregroundColor(.primary)
                    .toolbar {
                        Button {
                            sheetPresented = false
                        } label: {
                            Text("DONE")
                        }
                    }
#endif
            }
        }
    }

}

struct ChatEditor_Previews: PreviewProvider {
    static var previews: some View {
        ChatEditor(model: .init(name: "", temperature: .balanced, systemMessage: "", historyLengthToSend: 0, messagePrefix: "", autoCopy: false, icon: .default, color: .default, model: Chat.OpenAIModel.default.rawValue)) {

        }
    }
}
