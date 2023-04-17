//
//  ChatsView.swift
//  AssisChat
//
//  Created by Nooc on 2023-03-05.
//

import SwiftUI

struct ChatsView: View {
    var body: some View {
        ChatList()
        .toolbar {
            ToolbarItem {
                NavigationLink {
                    SettingsView()
                        .navigationTitle("SETTINGS")
                } label: {
                    Label("SETTINGS", systemImage: "gearshape")
                }
            }
        }
    }
}

private struct ChatList: View {
    @EnvironmentObject var settingsFeature: SettingsFeature
    @EnvironmentObject var chatFeature: ChatFeature

    @FetchRequest(
        sortDescriptors: [
            SortDescriptor(\.rawPinOrder, order: .reverse),
            SortDescriptor(\.rawUpdatedAt, order: .reverse)
        ]
    ) var chats: FetchedResults<Chat>

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if !chats.isEmpty {
                chatList
            } else if !settingsFeature.adapterReady {
                configIncorrect
            } else {
                listEmpty
            }

            ChatCreatingButton()
        }
    }

    var configIncorrect: some View {
        VStack {
            Image(systemName: "bubble.left.and.exclamationmark.bubble.right")
                .resizable()
                .scaledToFit()
                .frame(width: 80)
                .symbolVariant(.square)
                .foregroundColor(.appOrange)

            Text("You have not set the chat source correctly. Please set it correctly to continue.")
                .foregroundColor(.secondary)
                .font(.subheadline)
                .padding()

            NavigationLink {
                ChatSourceConfigView(successAlert: false, backWhenConfigured: true) {
                    if chats.isEmpty {
                        chatFeature.createPresets(presets: ChatPreset.presetsAutoCreate)
                    }
                }
            } label: {
                Text("Go to set chat source")
            }

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    var listEmpty: some View {
        VStack {
            Image(systemName: "eyeglasses")
                .resizable()
                .scaledToFit()
                .frame(width: 80)
                .symbolVariant(.square)
                .foregroundColor(.secondary)

            Text("CHATS_EMPTY_HINT")
                .foregroundColor(.secondary)
                .font(.subheadline)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    var chatList: some View {
        List {
            if !settingsFeature.adapterReady {
                NavigationLink {
                    ChatSourceConfigView(successAlert: false, backWhenConfigured: true) {
                        if chats.isEmpty {
                            chatFeature.createPresets(presets: ChatPreset.presetsAutoCreate)
                        }
                    }
                } label: {
                    Label("Go to set chat source", systemImage: "exclamationmark.triangle")
                        .foregroundColor(.white)
                }
                .listRowBackground(Color.appOrange)
            }

            ForEach(chats) { chat in
                NavigationLink {
                    ChattingView(chat: chat)
                } label: {
                    ChatItem(chat: chat)
                }
                .listRowBackground(chat.pinned ? Color.secondaryBackground : Color.clear)
                .swipeActions(edge: .leading, content: {
                    Button {
                        chatFeature.clearMessages(for: chat)
                    } label: {
                        Label("CHAT_CLEAR_MESSAGE", systemImage: "eraser.line.dashed")
                    }

                    if chat.pinned {
                        Button {
                            chatFeature.unpinChat(chat: chat)
                        } label: {
                            Label("Unpin Chat", systemImage: "pin.slash")
                        }
                    } else {
                        Button {
                            chatFeature.pinChat(chat: chat)
                        } label: {
                            Label("Pin Chat", systemImage: "pin")
                        }
                    }
                })
                .contextMenu {
                    if chat.pinned {
                        Button {
                            chatFeature.unpinChat(chat: chat)
                        } label: {
                            Label("Unpin Chat", systemImage: "pin.slash")
                        }
                    } else {
                        Button {
                            chatFeature.pinChat(chat: chat)
                        } label: {
                            Label("Pin Chat", systemImage: "pin")
                        }
                    }

                    Button {
                        chatFeature.clearMessages(for: chat)
                    } label: {
                        Label("CHAT_CLEAR_MESSAGE", systemImage: "eraser.line.dashed")
                    }

                    Divider()

                    Button(role: .destructive) {
                        chatFeature.deleteChats([chat])
                    } label: {
                        Label("CHAT_DELETE", systemImage: "trash")
                    }
                }
            }
            .onDelete(perform: onDelete)

            CopyrightView()
                .padding(.vertical, 30)
                .listRowSeparator(.hidden)
        }
        #if os(iOS)
        .listStyle(.plain)
        #endif
        .animation(.easeOut, value: chats.count)
    }

    func onDelete(_ indices: IndexSet) {
        chatFeature.deleteChats(indices.map({ index in
            chats[index]
        }))
    }
}

private struct ChatItem: View {
    @ObservedObject var chat: Chat

    var body: some View {
        HStack {
            chat.icon.image
                .font(.title2)
                .frame(width: 24, height: 24)
            #if os(iOS)
                .padding(13)
            #else
                .padding(10)
            #endif
                .background(chat.uiColor)
                .cornerRadius(8)
                .colorScheme(.dark)

            VStack(alignment: .leading, spacing: 5) {
                Text(chat.name)
                Text(chat.systemMessage ?? String(localized: "CHAT_ROLE_PROMPT_BLANK_HINT"))
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
    }
}

private struct ChatCreatingButton: View {
    @State var creating = false

    var body: some View {
        Button {
            creating = true
        } label: {
            Image(systemName: "plus")
                .aspectRatio(1, contentMode: .fit)
                .font(.title2)
                .padding()
                .foregroundColor(.primary)
                .background(Color.accentColor)
                .cornerRadius(.infinity)
                .colorScheme(.dark)
                .padding()
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $creating) {
#if os(iOS)
            NavigationView {
                NewChatView()
                    .navigationTitle("NEW_CHAT_NAME")
                    .inlineNavigationBar()
            }
#else
            NewChatView()
                .navigationTitle("NEW_CHAT_NAME")
                .inlineNavigationBar()
                .frame(width: 300, height: 500)
#endif
        }
    }
}

struct ChatsView_Previews: PreviewProvider {
    static var previews: some View {
        ChatsView()
    }
}
