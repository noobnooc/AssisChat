//
//  ChattingView.swift
//  AssisChat
//
//  Created by Nooc on 2023-03-05.
//

import SwiftUI
import MarkdownUI

struct ChattingView: View {
    @EnvironmentObject private var chattingFeature: ChattingFeature

    @ObservedObject var chat: Chat
    @State var activeMessageId: ObjectIdentifier?

    var body: some View {
        VStack(spacing: 0) {
            let scrollView = ScrollView {
                Rectangle()
                    .fill(.clear)
                    .frame(height: 10)

                ForEach(chat.messages.reversed()) { message in
                    MessageItem(message: message, activation: $activeMessageId)
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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    ChatDetailView(chat: chat)
                        .navigationTitle("CHAT_DETAIL")
                } label: {
                    Label("CHAT_DETAIL", systemImage: "info.circle")
                }
            }
        }
    }
}

private struct MessageItem: View {
    @EnvironmentObject private var messageFeature: MessageFeature

    @ObservedObject var message: Message
    @Binding var activation: ObjectIdentifier?

    var active: Bool {
        activation == message.id
    }

    var body: some View {
        if message.role == .assistant {
            AssistantMessage(message: message, active: active) {
                toggleActive()
            }
        } else {
            UserMessage(message: message, active: active) {
                toggleActive()
            }
        }
    }

    func toggleActive() {
        withAnimation {
            if (active) {
                activation = nil
            } else {
                activation = message.id
            }
        }
    }
}

private struct AssistantMessage: View {
    @EnvironmentObject private var messageFeature: MessageFeature

    let message: Message
    let active: Bool
    let toggleActive: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                VStack(alignment: .trailing) {
                    if let content = message.content {
                        Markdown(content.trimmingCharacters(in: .whitespacesAndNewlines))
                    } else if message.receiving {
                        ProgressView()
                    } else if message.failed {
                        Label("ERROR", systemImage: "info.circle")
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 15)
                .background(message.failed ? Color.appRed : Color.secondaryBackground)
                .foregroundColor(message.failed ? Color.white : Color.primary)
                .cornerRadius(15, corners: [.bottomRight, .topRight, .topLeft])
                .textSelection(.enabled)
                .onTapGesture {
                    toggleActive()
                }

                Spacer(minLength: 50)
            }

            if active && !message.receiving {
                HStack {
                    Button(role: .destructive) {
                        withAnimation {
                            messageFeature.deleteMessages([message])
                        }
                    } label: {
                        Image(systemName: "trash")
                    }
                    .padding(5)
                    .background(Color.tertiaryBackground)
                    .cornerRadius(.infinity)
                }
                .padding(5)
                .background(Color.secondaryBackground)
                .cornerRadius(15, corners: [.topRight, .bottomRight, .bottomLeft])
                .animation(.easeOut(duration: 0.1), value: active)
                .transition(.scale(scale: 0, anchor: .top))
            }
        }
    }
}


private struct UserMessage: View {
    @EnvironmentObject private var messageFeature: MessageFeature

    let message: Message
    let active: Bool
    let toggleActive: () -> Void

    var body: some View {
        VStack(alignment: .trailing, spacing: 2) {
            HStack {
                Spacer(minLength: 50)
                Markdown((message.content ?? "").trimmingCharacters(in: .whitespacesAndNewlines))
                    .padding(.vertical, 8)
                    .padding(.horizontal, 15)
                    .background(Color.accentColor)
                    .cornerRadius(15, corners: [.bottomLeft, .topLeft, .topRight])
                    .colorScheme(.dark)
                    .textSelection(.enabled)
                    .onTapGesture {
                        toggleActive()
                    }
            }

            if (active) {
                HStack {
                    Button(role: .destructive) {
                        withAnimation {
                            messageFeature.deleteMessages([message])
                        }
                    } label: {
                        Image(systemName: "trash")
                    }
                    .padding(5)
                    .background(Color.tertiaryBackground)
                    .cornerRadius(.infinity)
                }
                .padding(5)
                .background(Color.secondaryBackground)
                .cornerRadius(15, corners: [.topLeft, .bottomLeft, .bottomRight])
                .animation(.easeOut(duration: 0.1), value: active)
                .transition(.scale(scale: 0, anchor: .top))
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
                    TextField("NEW_MESSAGE_HINT", text: $text, axis: .vertical)
                        .padding(8)
                        .background(.thinMaterial)
                        .cornerRadius(8)
                        .frame(minHeight: 45)
                        .lineLimit(1...3)
                } else {
                    TextField("NEW_MESSAGE_HINT", text: $text)
                        .padding(8)
                        .background(.thickMaterial)
                        .frame(minHeight: 45)
                        .cornerRadius(8)
                }

                Button {
                    Task {
                        let messageContent = text
                        text = ""

                        await chattingFeature.sendWithStream(
                            plainMessage: .init(
                                chat: chat,
                                role: .user,
                                content: messageContent,
                                processedContent: (chat.messagePrefix != nil ? "\(chat.messagePrefix!)\n\n" : "") + messageContent))
                    }

                } label: {
                    Image(systemName: "paperplane")
                }
                .frame(height: 45)
                .buttonStyle(.borderedProminent)
                .disabled(text.isEmpty || chat.receiving)
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
