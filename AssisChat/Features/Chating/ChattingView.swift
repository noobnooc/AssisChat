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
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(LocalizedStringKey(message.content.trimmingCharacters(in: .whitespacesAndNewlines)))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 15)
                        .background(Color.secondaryBackground)
                        .cornerRadius(15, corners: [.bottomRight, .topRight, .topLeft])
                        .textSelection(.enabled)
                        .onTapGesture {
                            toggleActive()
                        }

                    Spacer(minLength: 50)
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
                    .cornerRadius(15, corners: [.topRight, .bottomRight, .bottomLeft])
                    .animation(.easeOut(duration: 0.1), value: active)
                    .transition(.scale(scale: 0, anchor: .top))
                }
            }
        } else {
            VStack(alignment: .trailing, spacing: 2) {
                HStack {
                    Spacer(minLength: 50)
                    Text(LocalizedStringKey(message.content.trimmingCharacters(in: .whitespacesAndNewlines)))
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
