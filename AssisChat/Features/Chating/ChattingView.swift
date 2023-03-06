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

    @State var sending = false

    var body: some View {
        VStack(spacing: 0) {
            let scrollView = ScrollView {
                Rectangle()
                    .fill(.clear)
                    .frame(height: 10)

                if sending {
                    HStack {
                        ProgressView()
                            .padding(.vertical, 8)
                            .padding(.horizontal, 15)
                            .background(Color.secondaryBackground)
                            .cornerRadius(15, corners: [.bottomRight, .topRight, .topLeft])
                        Spacer(minLength: 50)
                    }
                    .padding(.horizontal, 10)
                    .scaleEffect(x: 1, y: -1, anchor: .center)
                }

                ForEach(chat.messages.reversed()) { message in
                    MessageItem(message: message)
                }
                .padding(.horizontal, 10)
                .scaleEffect(x: 1, y: -1, anchor: .center)

                Rectangle()
                    .fill(.clear)
                    .frame(height: 20)
            }
            .scaleEffect(x: 1, y: -1, anchor: .center)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                MessageInput(chat: chat, sending: $sending)
            }

            if #available(iOS 16, *) {
                scrollView
                    .scrollDismissesKeyboard(.interactively)
            } else {
                scrollView
            }
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
                    .background(Color.secondaryBackground)
                    .cornerRadius(15, corners: [.bottomRight, .topRight, .topLeft])
                Spacer(minLength: 50)
            } else {
                Spacer(minLength: 50)
                Text(message.content)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 15)
                    .background(Color.accentColor)
                    .cornerRadius(15, corners: [.bottomLeft, .topLeft, .topRight])
                    .colorScheme(.dark)
            }
        }
    }
}

private struct MessageInput: View {
    @EnvironmentObject private var chattingFeature: ChattingFeature

    @ObservedObject var chat: Chat
    @Binding var sending: Bool
    @State private var text = ""


    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(alignment: .bottom) {
                if #available(iOS 16.0, *) {
                    TextField("New Message", text: $text, axis: .vertical)
                        .padding(8)
                        .background(Color.background)
                        .cornerRadius(8)
                        .lineLimit(1...3)
                } else {
                    TextField("New Message", text: $text)
                        .padding(8)
                        .background(Color.background)
                        .cornerRadius(8)
                }

                Button {
                    Task {
                        let messageContent = text
                        text = ""

                        sending = true

                        await chattingFeature.sendMessage(plainMessage: .init(chat: chat, role: .user, content: messageContent))

                        sending = false
                    }

                } label: {
                    Image(systemName: "paperplane")
                }
                .buttonStyle(.borderedProminent)
                .disabled(text.isEmpty || sending)
            }
            .padding(10)
            .background(.regularMaterial)
        }
    }
}

struct ChattingView_Previews: PreviewProvider {
    static var previews: some View {
        ChattingView(chat: .init())
    }
}
