//
//  NewChatView.swift
//  AssisChat
//
//  Created by Nooc on 2023-03-05.
//

import SwiftUI

class NewChatViewModel: ObservableObject {
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

struct NewChatView: View {
    @Environment(\.dismiss) var dismiss

    @EnvironmentObject var chatFeature: ChatFeature

    @StateObject var model: NewChatViewModel = NewChatViewModel(
        name: "",
        temperature: .balanced,
        systemMessage: "",
        isolated: false,
        messagePrefix: "",
        icon: .default,
        color: .default
    )

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

            Section {
                Button {
                    create()
                    dismiss()
                } label: {
                    Text("Start Chat")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.primary)
                        .colorScheme(.dark)
                }
                .disabled(!model.available)
                .listRowInsets(EdgeInsets())
            }

            Section {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .listRowInsets(EdgeInsets())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.groupedBackground)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Start") {
                    create()
                    dismiss()
                }
                .disabled(!model.available)
                .buttonStyle(.borderedProminent)
            }
        }
    }

    func create() {
        let plainChat = model.plain

        guard plainChat.available else { return }

        chatFeature.createChat(plainChat)
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

struct NewChatView_Previews: PreviewProvider {
    static var previews: some View {
        NewChatView()
    }
}
