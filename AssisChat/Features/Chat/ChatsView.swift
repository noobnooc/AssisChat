//
//  ChatsView.swift
//  AssisChat
//
//  Created by Nooc on 2023-03-05.
//

import SwiftUI

#if os(iOS)
import LottieSwiftUI
#endif

struct ChatsView: View {
    @State private var logoPlaying = false

    var body: some View {
        ChatList()
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    QRCodeScannerButton()
                }

                ToolbarItem(placement: .principal) {
                    HStack {
                        LottieView(name: "logo-lottie", play: $logoPlaying)
                            .lottieLoopMode(.playOnce)
                            .frame(width: 20, height: 20)
                        Text("AssisChat")
                    }
                    .onTapGesture {
                        logoPlaying = true
                    }
                }
                #endif

                ToolbarItem {
                    #if os(iOS)
                    NavigationLink {
                        SettingsView()
                            .navigationTitle("SETTINGS")
                    } label: {
                        Label("SETTINGS", systemImage: "gearshape")
                    }
                    #else
                    if #available(macOS 14, *) {
                        SettingsLink(label: {
                            Label("SETTINGS", systemImage: "gearshape")
                        })
                    } else {
                        Button {
                            MacOSSettingsView.open()
                        } label: {
                            Label("SETTINGS", systemImage: "gearshape")
                        }
                    }
                    #endif
                }
            }
            .onAppear {
                logoPlaying = true
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

                #if os(iOS)
                NavigationLink {
                    ChatSourceConfigView(successAlert: false, backWhenConfigured: true) { adapter in
                        if chats.isEmpty {
                            chatFeature.createPresets(presets: ChatPreset.presetsAutoCreate, forModel: adapter.defaultModel)
                        }
                    }
                } label: {
                    Text("Go to set chat source")
                }
                #else
                if #available(macOS 14, *) {
                    SettingsLink(label: {
                        Text("Go to set chat source")
                    })
                } else {
                    Button {
                        MacOSSettingsView.open()
                    } label: {
                        Text("Go to set chat source")
                    }
                }
                #endif
            }
            .padding(10)
            .padding(.vertical)
            #if os(iOS)
            .background(Color.secondaryBackground)
            #else
            .background(Color.primary.opacity(0.1))
            #endif
            .cornerRadius(20)
            .padding(15)
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
                let label = Label {
                    Text("Go to set chat source")
                } icon: {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.appOrange)
                }

                #if os(iOS)
                NavigationLink {
                    ChatSourceConfigView(successAlert: false, backWhenConfigured: true) { _ in
                    }
                } label: {
                    label
                }
                .listRowBackground(Color.secondaryBackground)
                #else
                Button {
                    MacOSSettingsView.open()
                } label: {
                    label
                        .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
                #endif
            }

            ForEach(chats) { chat in
                NavigationLink {
                    ChattingView(chat: chat)
                } label: {
                    ChatItem(chat: chat)
                }
#if os(iOS)
                .listRowBackground(chat.pinned ? Color.secondaryBackground : Color.clear)
#endif
                .swipeActions(edge: .leading, content: {
                    Button {
                        chatFeature.clearMessages(for: chat)
                    } label: {
                        Label("CHAT_CLEAR_MESSAGE", systemImage: "eraser.line.dashed")
                            .background(Color.appOrange)
                    }
                    .tint(.appOrange)

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
                .padding(8)
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

#if os(macOS)
            if chat.pinned {
                Spacer()
                Image(systemName: "pin")
                    .foregroundColor(.secondary)
            }
#endif
        }
        #if os(macOS)
        .padding(.vertical, 2)
        #endif
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
                .shadow(color: .black.opacity(0.2), radius: 5)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $creating) {
            NavigationView {
                NewChatView()
                    .navigationTitle("NEW_CHAT_NAME")
                    .inlineNavigationBar()
                #if os(macOS)
                    .frame(width: 250)
                #endif

                ZStack(alignment: .topTrailing) {
                    Button {
                        creating = false
                    } label: {
                        Image(systemName: "multiply")
                    }
                    .buttonBorderShape(.roundedRectangle)
                    .padding()

                    VStack {
                        Image(systemName: "quote.bubble")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80)
                            .symbolVariant(.square)
                            .foregroundColor(.secondary)

                        Text("Select a preset or custom a chat")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                            .padding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
#if os(macOS)
            .frame(minHeight: 300, idealHeight: 500)
#endif
        }
    }
}

struct ChatsView_Previews: PreviewProvider {
    static var previews: some View {
        ChatsView()
    }
}
