//
//  ChattingView.swift
//  AssisChat
//
//  Created by Nooc on 2023-03-05.
//

import SwiftUI

struct ChattingView: View {
    @EnvironmentObject private var chattingFeature: ChattingFeature

    @ObservedObject var chat: Chat

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                Rectangle()
                    .fill(.clear)
                    .frame(height: 50)

                ForEach(chat.messages.reversed()) { message in
                    MessageItem(message: message)
                }
                .padding(.horizontal, 10)
                .scaleEffect(x: 1, y: -1, anchor: .center)
            }
            .scaleEffect(x: 1, y: -1, anchor: .center)

            MessageInput(chat: chat)
        }
        .navigationTitle(chat.name)
    }
}

private struct MessageItem: View {
    @ObservedObject var message: Message

    var body: some View {
        HStack {
            if message.role == .assistant {
                Text(message.content)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 15)
                    .background(Color.accentColor)
                    .cornerRadius(15)
                    .colorScheme(.dark)
                Spacer(minLength: 50)
            } else {
                Spacer(minLength: 50)
                Text(message.content)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 15)
                    .background(Color.secondaryBackground)
                    .cornerRadius(15)
            }
        }
    }
}

private struct MessageInput: View {
    @EnvironmentObject private var chattingFeature: ChattingFeature

    @ObservedObject var chat: Chat
    @State private var text = ""

    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack {
                TextField("New Message", text: $text)
                Button {
                    Task {
                        let messageContent = text
                        text = ""

                        await chattingFeature.sendMessage(plainMessage: .init(chat: chat, role: .user, content: messageContent))
                    }

                } label: {
                    Label("Send", systemImage: "paperplane")
                }
            }
            .padding()
            .background(.regularMaterial)
        }
    }
}

struct ChattingView_Previews: PreviewProvider {
    static var previews: some View {
        ChattingView(chat: .init())
    }
}
