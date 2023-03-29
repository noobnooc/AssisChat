//
//  ChatsView.swift
//  AssisChat
//
//  Created by Nooc on 2023-03-05.
//

import SwiftUI

struct ChatsView: View {
    @EnvironmentObject var chatFeature: ChatFeature

    @FetchRequest(
        sortDescriptors: [
            SortDescriptor(\.rawUpdatedAt, order: .reverse)
        ]
    ) var chats: FetchedResults<Chat>

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if !chats.isEmpty {
                List {
                    ForEach(chats) { chat in
                        NavigationLink {
                            ChattingView(chat: chat)
                        } label: {
                            ChatItem(chat: chat)
                        }
                        .swipeActions(edge: .leading, content: {
                            Button {
                                chatFeature.clearMessages(for: chat)
                            } label: {
                                Label("CHAT_CLEAR_MESSAGE", systemImage: "eraser.line.dashed")
                            }
                        })
                        .contextMenu {
                            Button {
                                chatFeature.clearMessages(for: chat)
                            } label: {
                                Label("CHAT_CLEAR_MESSAGE", systemImage: "eraser.line.dashed")
                            }
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
                .listStyle(.plain)
                .animation(.easeOut, value: chats.count)
            } else {
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
                        .padding(.top)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            ChatCreatingButton()
        }
        #if os(iOS)
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
        #endif
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
