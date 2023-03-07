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
        VStack(spacing: 0) {
            let scrollView = ScrollView {
                Rectangle()
                    .fill(.clear)
                    .frame(height: 10)

                if chat.sending || chat.failed {
                    HStack {
                        ZStack {
                            if chat.sending {
                                ProgressView()
                            } else {
                                Label("Retry", systemImage: "arrow.triangle.2.circlepath")
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 15)
                        .background(chat.failed ? Color.appRed : Color.secondaryBackground)
                        .cornerRadius(15, corners: [.bottomRight, .topRight, .topLeft])
                        .foregroundColor(chat.failed ? Color.white : Color.primary)
                        .onTapGesture {
                            if chat.failed {
                                Task {
                                    await chattingFeature.retry(chat: chat)
                                }
                            }
                        }

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
                    MessageInput(chat: chat)
                }
                .animation(.easeOut, value: chat)

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
    @EnvironmentObject private var messageFeature: MessageFeature

    @ObservedObject var message: Message

    var body: some View {
        HStack {
            if message.role == .assistant {
                Text(LocalizedStringKey(message.content.trimmingCharacters(in: .whitespacesAndNewlines)))
                    .padding(.vertical, 8)
                    .padding(.horizontal, 15)
                    .background(Color.secondaryBackground)
                    .cornerRadius(15, corners: [.bottomRight, .topRight, .topLeft])
                Spacer(minLength: 50)
            } else {
                Spacer(minLength: 50)
                Text(LocalizedStringKey(message.content.trimmingCharacters(in: .whitespacesAndNewlines)))
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
    @State private var text = ""


    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(alignment: .bottom) {
                if #available(iOS 16.0, *) {
                    TextField("New Message", text: $text, axis: .vertical)
                        .padding(8)
                        .background(.thinMaterial)
                        .cornerRadius(8)
                        .lineLimit(1...3)
                } else {
                    TextField("New Message", text: $text)
                        .padding(8)
                        .background(.thickMaterial)
                        .cornerRadius(8)
                }

                Button {
                    Task {
                        let messageContent = text
                        text = ""

                        await chattingFeature.send(
                            plainMessage: .init(
                                chat: chat,
                                role: .user,
                                content: messageContent,
                                processedContent: (chat.messagePrefix != nil ? "\(chat.messagePrefix!)\n\n" : "") + messageContent))
                    }

                } label: {
                    Image(systemName: "paperplane")
                }
                .buttonStyle(.borderedProminent)
                .disabled(text.isEmpty || chat.sending)
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
