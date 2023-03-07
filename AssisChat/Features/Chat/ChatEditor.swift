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
    @Published var icon: Chat.Icon
    @Published var color: Chat.Color?

    init(name: String, temperature: Chat.Temperature, systemMessage: String, isolated: Bool, messagePrefix: String, icon: Chat.Icon, color: Chat.Color?) {
        self.name = name
        self.temperature = temperature
        self.systemMessage = systemMessage
        self.isolated = isolated
        self.messagePrefix = messagePrefix
        self.icon = icon
        self.color = color
    }

    init(chat: Chat) {
        self.name = chat.name
        self.temperature = chat.temperature
        self.systemMessage = chat.systemMessage ?? ""
        self.isolated = chat.isolated
        self.messagePrefix = chat.messagePrefix ?? ""
        self.icon = chat.icon
        self.color = chat.color
    }

    var plain: PlainChat {
        PlainChat(
            name: name.isEmpty ? "New Chat" : name,
            temperature: temperature,
            systemMessage: systemMessage.count > 0 ? systemMessage : nil,
            isolated: isolated,
            messagePrefix: messagePrefix.count > 0 ? messagePrefix : nil,
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
            Section("Chat") {
                HStack(spacing: 0) {
                    IconSelectorButton(selection: $model.icon)
                        .padding()
                        .background(model.color?.color ?? Chat.Color.default.color)
                        .foregroundColor(Color.secondaryGroupedBackground)
                        .cornerRadius(10)

                    TextField("New Chat", text: $model.name)
                        .font(.title3)
                        .padding()
                }

                ColorSelector(selection: $model.color)
                    .padding(.vertical, 5)
            }

            Section("Config") {
                Picker("Temperature", selection: $model.temperature) {
                    Text("Creative")
                        .tag(Chat.Temperature.creative)

                    Text("Balanced")
                        .tag(Chat.Temperature.balanced)

                    Text("Precise")
                        .tag(Chat.Temperature.precise)
                }

                VStack(alignment: .leading) {
                    Text("Role Prompt")
                        .font(.footnote)
                        .foregroundColor(Color.secondary)

                    if #available(iOS 16, *) {
                        TextField("Set the behavior of the assistant", text: $model.systemMessage, axis: .vertical)
                            .lineLimit(1...3)
                    } else {
                        TextField("Set the behavior of the assistant", text: $model.systemMessage)
                    }
                }

                VStack(alignment: .leading) {
                    Text("Message Prefix")
                        .font(.footnote)
                        .foregroundColor(Color.secondary)

                    if #available(iOS 16, *) {
                        TextField("Will be added before each message", text: $model.messagePrefix, axis: .vertical)
                            .lineLimit(1...3)
                    } else {
                        TextField("Will be added before each message", text: $model.messagePrefix)
                    }
                }

                VStack(alignment: .trailing) {
                    Toggle(isOn: $model.isolated) {
                        Text("Isolated")
                    }

                    Text("Isolated chat will not send history messages")
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
                        .navigationTitle("Select an icon")
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationBarItems(trailing: Button("Done", action: {
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
        ChatEditor(model: .init(name: "Hello", temperature: .balanced, systemMessage: "", isolated: false, messagePrefix: "", icon: .default, color: .default)) {

        }
    }
}
