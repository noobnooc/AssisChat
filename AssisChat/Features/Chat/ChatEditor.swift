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
    @Published var isolated: Bool
    @Published var messagePrefix: String
    @Published var autoCopy: Bool
    @Published var icon: Chat.Icon
    @Published var color: Chat.Color?

    init(name: String, temperature: Chat.Temperature, systemMessage: String, isolated: Bool, messagePrefix: String, autoCopy: Bool, icon: Chat.Icon, color: Chat.Color?) {
        self.name = name
        self.temperature = temperature
        self.systemMessage = systemMessage
        self.isolated = isolated
        self.messagePrefix = messagePrefix
        self.autoCopy = autoCopy
        self.icon = icon
        self.color = color
    }

    init(chat: Chat) {
        self.name = chat.name
        self.temperature = chat.temperature
        self.systemMessage = chat.systemMessage ?? ""
        self.isolated = chat.isolated
        self.messagePrefix = chat.messagePrefix ?? ""
        self.autoCopy = chat.autoCopy
        self.icon = chat.icon
        self.color = chat.color
    }

    var plain: PlainChat {
        PlainChat(
            name: name.isEmpty ? String(localized: "NEW_CHAT_NAME") : name,
            temperature: temperature,
            systemMessage: systemMessage.count > 0 ? systemMessage : nil,
            isolated: isolated,
            messagePrefix: messagePrefix.count > 0 ? messagePrefix : nil,
            autoCopy: autoCopy,
            icon: icon,
            color: color
        )
    }

    var available: Bool {
        plain.available
    }
}

struct ChatEditor<Actions: View>: View {
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
                }

                ColorSelector(selection: $model.color)
                    .padding(.vertical, 5)
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

                VStack(alignment: .leading) {
                    Text("CHAT_ROLE_PROMPT")
                        .font(.footnote)
                        .foregroundColor(Color.secondary)

                    if #available(iOS 16, *) {
                        TextField("CHAT_ROLE_PROMPT_HINT", text: $model.systemMessage, axis: .vertical)
                            .lineLimit(1...3)
                    } else {
                        TextField("CHAT_ROLE_PROMPT_HINT", text: $model.systemMessage)
                    }
                }

                VStack(alignment: .leading) {
                    Text("CHAT_MESSAGE_PREFIX")
                        .font(.footnote)
                        .foregroundColor(Color.secondary)

                    if #available(iOS 16, *) {
                        TextField("CHAT_MESSAGE_PREFIX_HINT", text: $model.messagePrefix, axis: .vertical)
                            .lineLimit(1...3)
                    } else {
                        TextField("CHAT_MESSAGE_PREFIX_HINT", text: $model.messagePrefix)
                    }
                }

                VStack(alignment: .trailing) {
                    Toggle(isOn: $model.isolated) {
                        Text("CHAT_ISOLATED")
                    }

                    Text("CHAT_ISOLATED_HINT")
                        .font(.footnote)
                        .foregroundColor(Color.secondary)
                }

                VStack(alignment: .trailing) {
                    Toggle(isOn: $model.autoCopy) {
                        Text("CHAT_AUTO_COPY")
                    }

                    Text("CHAT_AUTO_COPY_HINT")
                        .font(.footnote)
                        .foregroundColor(Color.secondary)
                }
            }

            actions
        }
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
            .sheet(isPresented: $sheetPresented) {
                NavigationView {
                    ChatIconSelector(selection: $selection)
                        .navigationTitle("CHAT_EDITOR_ICON_SELECTOR_TITLE")
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationBarItems(trailing: Button("DONE", action: {
                            sheetPresented = false
                        }))
                        .foregroundColor(.primary)
                }
            }
        }
    }

}

struct ChatEditor_Previews: PreviewProvider {
    static var previews: some View {
        ChatEditor(model: .init(name: "", temperature: .balanced, systemMessage: "", isolated: false, messagePrefix: "", autoCopy: false, icon: .default, color: .default)) {

        }
    }
}
