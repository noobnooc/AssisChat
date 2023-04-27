//
//  ChatDetailView.swift
//  AssisChat
//
//  Created by Nooc on 2023-03-07.
//

import SwiftUI

struct ChatDetailView: View {
    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject private var chatFeature: ChatFeature

    @ObservedObject var chat: Chat

    @State private var editing = false

    var body: some View {
        List {
            Section {
                VStack {
                    chat.icon.image
                        .font(.title2)
                        .frame(width: 50, height: 50)
                        .background(chat.uiColor)
                        .colorScheme(.dark)
                        .cornerRadius(12)

                    Text(chat.name)

                    HStack {
                        Text(chat.model ?? "unknown")
                            .lineLimit(1)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .background(Color.appBlue)
                            .cornerRadius(.infinity)

                        Text(chat.temperature.display)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .background(chat.temperature.color)
                            .cornerRadius(.infinity)

                        HStack(spacing: 2) {
                            Text("CHAT_HISTORY_LENGTH_TO_SEND")
                                .lineLimit(1)
                            Text(chat.storedHistoryLengthToSend.historyLengthToSendDisplay)
                                .lineLimit(1)
                                .opacity(0.8)
                        }
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .background(Color.appOrange)
                        .cornerRadius(.infinity)

                    }
                    .lineLimit(nil)
                    .font(.subheadline)
                    .colorScheme(.dark)
                    .padding(.top)
                }
                .frame(maxWidth: .infinity)
            }
            .listRowBackground(Color.clear)

            if let systemMessage = chat.systemMessage {
                Section("CHAT_ROLE_PROMPT") {
                    Text(systemMessage)
                        .foregroundColor(Color.secondary)
                }
            }

            if chat.messagePrefix != nil {
                Section("CHAT_EDITOR_CONFIG_SECTION") {
                    if let messagePrefix = chat.messagePrefix {
                        VStack(alignment: .leading) {
                            Text("CHAT_MESSAGE_PREFIX")
                                .font(.footnote)
                                .foregroundColor(Color.secondary)
                            
                            Text(messagePrefix)
                                .padding(.top, 5)
                        }
                    }
                }
            }
        }
        .toolbar {
            Menu {
                Button {
                    editing = true
                } label: {
                    Label("EDIT", systemImage: "pencil")
                }

                Button {
                    chatFeature.clearMessages(for: chat)
                } label: {
                    Label("CHAT_CLEAR_MESSAGE", systemImage: "eraser.line.dashed")
                }
            } label: {
                Label("CHAT_ACTIONS", systemImage: "ellipsis")
            }
        }
        .sheet(isPresented: $editing) {
#if os(iOS)
            NavigationView {
                EditChatView(chat: chat)
                    .navigationTitle("CHAT_EDIT")
                    .inlineNavigationBar()
            }
#else
            EditChatView(chat: chat)
                .frame(width: 300, height: 500)
#endif
        }
#if os(macOS)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                }

            }
        }
#endif
    }
}

struct ChatDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ChatDetailView(chat: .init())
    }
}
