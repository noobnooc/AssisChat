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
    @State var activeMessageId: ObjectIdentifier?

    @FetchRequest
    private var messages: FetchedResults<Message>

    init(chat: Chat) {
        _chat = ObservedObject(wrappedValue: chat)
        _messages = FetchRequest<Message>(
            sortDescriptors: [NSSortDescriptor(keyPath: \Message.rawTimestamp, ascending: false)],
            predicate: chat.predicate
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            if messages.isEmpty {
                MessagesEmpty()
            } else {
                let scrollView = messagesListView()

                if #available(iOS 16, macOS 13, *) {
                    scrollView
                        .scrollDismissesKeyboard(.immediately)
                } else {
                    scrollView
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            MessageInput(chat: chat)
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

    @ViewBuilder
    private func messagesListView() -> some View {
        ScrollView {
            Rectangle()
                .fill(.clear)
                .frame(height: 10)

            ForEach(messages) { (message: Message) in
                MessageItem(message: message, activation: $activeMessageId)
            }
            .padding(.horizontal, 10)
            .scaleEffect(x: 1, y: -1, anchor: .center)

            Rectangle()
                .fill(.clear)
                .frame(height: 20)
        }
        .scaleEffect(x: 1, y: -1, anchor: .center)
        .animation(.easeOut, value: messages.count)
    }
}

private struct MessagesEmpty: View {
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    Image(systemName: "bubble.right")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color.appGreen)

                    Text("Send message directly")
                }

                NavigationLink {
                    ShareExtensionIntroduction()
                } label: {
                    HStack(alignment: .top) {
                        Image(systemName: "square.and.arrow.up")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(Color.appOrange)

                        Text("Share text from other apps with **Share Extension**")
                            .multilineTextAlignment(.leading)
                    }
                }

                NavigationLink {
                    KeyboardExtensionIntroduction()
                } label: {
                    HStack(alignment: .top) {
                        Image(systemName: "keyboard")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(Color.appBlue)

                        Text("Integrate with input field through **Keyboard Extension**")
                            .multilineTextAlignment(.leading)
                    }
                }
            }
            .foregroundColor(.secondary)
            .frame(alignment: .leading)
            .padding()
            #if os(macOS)
            .background(Color.primary.opacity(0.1))
            #else
            .background(Color.secondaryBackground)
            #endif
            .cornerRadius(15)
            .padding()
        }
        .frame(maxHeight: .infinity)
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
                Haptics.veryLight()
            }
        } else {
            UserMessage(message: message, active: active) {
                toggleActive()
                Haptics.veryLight()
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
    @EnvironmentObject private var chattingFeature: ChattingFeature

    let message: Message
    let active: Bool
    let toggleActive: () -> Void

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            HStack {
                VStack(alignment: .trailing) {
                    if let content = message.content {
                        MessageContent(content: content)
                    } else if message.receiving {
                        UniformProgressView()
                    } else if let reason = message.failedReason {
                        Label(reason.localized, systemImage: "info.circle")
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 15)
                .foregroundColor(message.failed ? Color.white : Color.primary)
#if os(iOS)
                .background(message.failed ? Color.appRed : Color.secondaryBackground)
                .cornerRadius(15, corners: [.bottomRight, .topRight, .topLeft])
#else
                .background(message.failed ? Color.appRed : Color.primary.opacity(0.1))
                .cornerRadius(10)
#endif
                .onTapGesture {
                    toggleActive()
                }

                Spacer(minLength: 50)
            }
            .overlay(alignment: .bottomLeading) {
                if active && !message.receiving {
                    HStack {
                        Button(role: .destructive) {
                            withAnimation {
                                messageFeature.deleteMessages([message])
                            }
                        } label: {
                            Image(systemName: "trash")
                                .padding(6)
                                .foregroundColor(.appRed)
                        }
                        .buttonStyle(.plain)

                        Divider()
                            .padding(.vertical, 4)

                        Button {
                            withAnimation {
                                message.copyToPasteboard()
                                toggleActive()
                            }
                        } label: {
                            Image(systemName: "doc.on.doc")
                                .padding(6)
                                .foregroundColor(.appBlue)
                        }
                        .buttonStyle(.plain)

                        Button {
                            withAnimation {
                                toggleActive()

                                Task {
                                    await chattingFeature.resendWithStream(receivingMessage: message)
                                }
                            }
                        } label: {
                            Image(systemName: "arrow.clockwise")
                                .padding(6)
                                .foregroundColor(.appOrange)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 2)
                    .padding(.horizontal, 9)
                    .frame(height: 30)
                    .background(Color.secondaryBackground)
                    .cornerRadius(.infinity)
                    .transition(.scale(scale: 0, anchor: .bottomLeading).animation(.spring().speed(2)))
                    .overlay(
                        RoundedRectangle(cornerRadius: .infinity)
                            .stroke(Color.accentColor, lineWidth: 1)
                    )
                    .padding(3)
                }
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
        HStack {
            Spacer(minLength: 50)
            MessageContent(content: message.content ?? "")
                .padding(.vertical, 8)
                .padding(.horizontal, 15)
                .background(Color.accentColor)
#if os(iOS)
                .cornerRadius(15, corners: [.bottomLeft, .topLeft, .topRight])
#else
                .cornerRadius(10)
#endif
                .colorScheme(.dark)
                .onTapGesture {
                    toggleActive()
                }
        }
        .overlay(alignment: .bottomTrailing) {
            if (active) {
                HStack {
                    Button {
                        withAnimation {
                            message.copyToPasteboard()
                            toggleActive()
                        }
                    } label: {
                        Image(systemName: "doc.on.doc")
                            .padding(5)
                            .foregroundColor(.appBlue)
                    }
                    .buttonStyle(.plain)

                    Divider()
                        .padding(.vertical, 5)

                    Button(role: .destructive) {
                        withAnimation {
                            messageFeature.deleteMessages([message])
                        }
                    } label: {
                        Image(systemName: "trash")
                            .padding(5)
                            .foregroundColor(.appRed)

                    }
                    .buttonStyle(.plain)
                }
                .padding(.vertical, 2)
                .padding(.horizontal, 9)
                .frame(height: 30)
                .background(Color.secondaryBackground)
                .cornerRadius(.infinity)
                .transition(.scale(scale: 0, anchor: .bottomTrailing).animation(.spring().speed(2)))
                .overlay(
                    RoundedRectangle(cornerRadius: .infinity)
                        .stroke(Color.accentColor, lineWidth: 1)
                )
                .padding(3)
            }
        }
    }
}

private struct MessageInput: View {
    @EnvironmentObject private var settingsFeature: SettingsFeature
    @EnvironmentObject private var chattingFeature: ChattingFeature

    @ObservedObject var chat: Chat
    @State private var text = ""

    var adapterReady: Bool {
        chat.model != nil && settingsFeature.modelToAdapter[chat.model!] != nil
    }

    var sendButtonAvailable: Bool {
        !text.isEmpty && !chat.receiving && adapterReady
    }

    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(alignment: .bottom) {
                if #available(iOS 16.0, macOS 13.0, *) {
                    TextField(adapterReady ? String(localized: "NEW_MESSAGE_HINT") : String(localized: "The model \"\(chat.model ?? "unknown")\" is not available"), text: $text, axis: .vertical)
                        .padding(8)
                        .background(Color.primary.opacity(0.05))
                        .cornerRadius(8)
                        .frame(minHeight: 45)
                        .lineLimit(1...3)
                        .textFieldStyle(.plain)
                        .disabled(!adapterReady)
#if os(macOS)
                        .onSubmit {
                            submit()
                        }
#endif
                } else {
                    TextField(adapterReady ? String(localized: "NEW_MESSAGE_HINT") : String(localized: "The model \"\(chat.model ?? "unknown")\" is not available"), text: $text)
                        .padding(8)
                        .background(Color.primary.opacity(0.05))
                        .frame(minHeight: 45)
                        .cornerRadius(8)
                        .textFieldStyle(.plain)
                        .disabled(!adapterReady)
#if os(macOS)
                        .onSubmit {
                            submit()
                        }
#endif
                }

                Button {
                    submit()
                } label: {
                    if chat.receiving {
                        UniformProgressView()
                            .tint(.accentColor)
                    } else {
                        Image(systemName: "paperplane")
                            .foregroundColor(sendButtonAvailable ? Color.white : Color.primary.opacity(0.2))
                    }
                }
                .buttonStyle(.plain)
#if os(iOS)
                .frame(width: 41, height: 41)
#else
                .frame(width: 31, height: 31)
#endif
                .background(sendButtonAvailable ? Color.accentColor : Color.primary.opacity(0.05))
                .cornerRadius(.infinity)
                .padding(2)
#if os(macOS)
                .padding(.vertical, 5)
#endif
                .clipShape(Rectangle())
                .disabled(!sendButtonAvailable)
            }
#if os(iOS)
            .padding(10)
#else
            .padding(5)
#endif
            .background(.regularMaterial)
        }
    }

    func submit() {
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
    }
}

struct ChattingView_Previews: PreviewProvider {
    static var previews: some View {
        ChattingView(chat: .init())
    }
}
