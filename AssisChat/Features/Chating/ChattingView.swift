//
//  ChattingView.swift
//  AssisChat
//
//  Created by Nooc on 2023-03-05.
//

import SwiftUI
import Splash
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

            if #available(iOS 16, macOS 13, *) {
                scrollView
                    .scrollDismissesKeyboard(.interactively)
            } else {
                scrollView
            }
        }
        .navigationTitle(chat.name)
        .inlineNavigationBar()
        .toolbar {
            ToolbarItem() {
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
                        MessageContent(content: content)
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
                #if os(iOS)
                .cornerRadius(15, corners: [.bottomRight, .topRight, .topLeft])
                #else
                .cornerRadius(15)
                #endif
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
                    .buttonStyle(.plain)
                    .foregroundColor(.appRed)

                    Divider()
                        .padding(.vertical)

                    Button {
                        withAnimation {
                            message.copyToPasteboard()
                            toggleActive()
                        }
                    } label: {
                        Image(systemName: "doc.on.doc")
                    }
                    .padding(5)
                    .foregroundColor(.appBlue)
                    .background(Color.tertiaryBackground)
                    .cornerRadius(.infinity)
                    .buttonStyle(.plain)
                }
                .padding(5)
                .background(Color.secondaryBackground)
                #if os(iOS)
                .cornerRadius(15, corners: [.topRight, .bottomRight, .bottomLeft])
                #else
                .cornerRadius(15)
                #endif
                .animation(.spring(), value: active)
                .transition(.scale(scale: 0, anchor: .topLeading))
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
                MessageContent(content: message.content ?? "")
                    .padding(.vertical, 8)
                    .padding(.horizontal, 15)
                    .background(Color.accentColor)
                #if os(iOS)
                    .cornerRadius(15, corners: [.bottomLeft, .topLeft, .topRight])
                #else
                    .cornerRadius(15)
                #endif
                    .colorScheme(.dark)
                    .onTapGesture {
                        toggleActive()
                    }
            }

            if (active) {
                HStack {
                    Button {
                        withAnimation {
                            message.copyToPasteboard()
                            toggleActive()
                        }
                    } label: {
                        Image(systemName: "doc.on.doc")
                    }
                    .padding(5)
                    .foregroundColor(.appBlue)
                    .background(Color.tertiaryBackground)
                    .cornerRadius(.infinity)
                    .buttonStyle(.plain)

                    Divider()
                        .padding(.vertical)

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
                    .buttonStyle(.plain)
                    .foregroundColor(.appRed)
                }
                .padding(5)
                .background(Color.secondaryBackground)
                #if os(iOS)
                .cornerRadius(15, corners: [.topLeft, .bottomLeft, .bottomRight])
                #else
                .cornerRadius(15)
                #endif
                .animation(.spring(), value: active)
                .transition(.scale(scale: 0, anchor: .topTrailing))
            }
        }
    }
}

private struct MessageContent: View {
    let content: String

    var body: some View {
        Markdown(content.trimmingCharacters(in: .whitespacesAndNewlines))
            .markdownTextStyle(\.link, textStyle: {
                UnderlineStyle(.single)
                ForegroundColor(.primary.opacity(0.8))
            })
            .markdownBlockStyle(\.codeBlock) { configuration in
                ScrollView(.horizontal) {
                    configuration.label
                        .padding(10)
                }
                .markdownTextStyle(textStyle: {
                    FontFamilyVariant(.monospaced)
                    FontSize(.em(0.85))
                })
                .background(Color.primary.opacity(0.1))
                .cornerRadius(8)
                .padding(.bottom)
                .textSelection(.enabled)
                //                                TODO: - Get the content
                //                                .overlay(alignment: .bottomTrailing) {
                //                                    Button {
                //
                //                                    } label: {
                //                                        Image(systemName: "doc.on.doc")
                //                                    }
                //                                    .tint(.secondary)
                //                                    .frame(height: 25)
                //                                    .buttonStyle(.borderedProminent)
                //                                    .padding(10)
                //                                }
            }
    }
}

private struct MessageInput: View {
    @EnvironmentObject private var chattingFeature: ChattingFeature

    @ObservedObject var chat: Chat
    @State private var text = ""

    var sendButtonAvailable: Bool {
        !text.isEmpty && !chat.receiving
    }

    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(alignment: .bottom) {
                if #available(iOS 16.0, macOS 13.0, *) {
                    TextField("NEW_MESSAGE_HINT", text: $text, axis: .vertical)
                        .padding(8)
                        .background(Color.primary.opacity(0.05))
                        .cornerRadius(8)
                        .frame(minHeight: 45)
                        .lineLimit(1...3)
                        .textFieldStyle(.plain)
                } else {
                    TextField("NEW_MESSAGE_HINT", text: $text)
                        .padding(8)
                        .background(Color.primary.opacity(0.05))
                        .frame(minHeight: 45)
                        .cornerRadius(8)
                        .textFieldStyle(.plain)
                }

                Button {
                    guard sendButtonAvailable else { return }
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
                    if chat.receiving {
                        ProgressView()
                            .tint(.accentColor)
                        #if os(macOS)
                            .frame(width: 20, height: 20)
                        #endif
                    } else {
                        Image(systemName: "paperplane")
                            .foregroundColor(sendButtonAvailable ? Color.white : Color.primary.opacity(0.2))
                    }
                }
                .buttonStyle(.plain)
                .frame(width: 41, height: 41)
                .background(sendButtonAvailable ? Color.accentColor : Color.primary.opacity(0.05))
                .cornerRadius(.infinity)
                .padding(2)
                .clipShape(Rectangle())
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
