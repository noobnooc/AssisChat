//
//  ChatsView.swift
//  AssisChat
//
//  Created by Nooc on 2023-03-05.
//

import SwiftUI

struct ChatsView: View {
    @EnvironmentObject var chatFeature: ChatFeature

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            List {
                ForEach(chatFeature.orderedChats) { chat in
                    NavigationLink {
                        ChattingView(chat: chat)
                    } label: {
                        ChatItem(chat: chat)
                    }
                }
                .onDelete(perform: onDelete)
            }
            .listStyle(.plain)

            ChatCreatingButton()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    SettingsView()
                        .navigationTitle("Settings")
                } label: {
                    Label("Settings", systemImage: "gearshape")
                }
            }
        }
    }

    func onDelete(_ indices: IndexSet) {
        chatFeature.deleteChats(indices.map({ index in
            chatFeature.chats[index]
        }))
    }
}

private struct ChatItem: View {
    @ObservedObject var chat: Chat

    var body: some View {
        HStack {
            chat.icon.image
                .frame(width: 24, height: 24)
                .padding()
                .background(chat.uiColor)
                .cornerRadius(10)
                .colorScheme(.dark)

            VStack(alignment: .leading) {
                Text(chat.name)
                Text(chat.systemMessage ?? "General Chat")
                    .font(.footnote)
                    .foregroundColor(.secondary)
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
                .font(.title2)
                .padding()
                .foregroundColor(.primary)
                .background(Color.accentColor)
                .cornerRadius(.infinity)
                .colorScheme(.dark)
                .padding()
        }
        .padding(10)
        .sheet(isPresented: $creating) {
            NavigationView {
                NewChatView()
                    .navigationTitle("New Chat")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

struct ChatsView_Previews: PreviewProvider {
    static var previews: some View {
        ChatsView()
    }
}
