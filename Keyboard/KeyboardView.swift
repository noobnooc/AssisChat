//
//  KeyboardView.swift
//  Keyboard
//
//  Created by Nooc on 2023-05-10.
//

import SwiftUI

struct KeyboardView: View {
    @Environment(\.openURL) private var openURL

    @EnvironmentObject private var messageFeature: MessageFeature
    @EnvironmentObject private var chattingFeature: ChattingFeature

    @State private var receivingMessage: Message?

    var viewController: KeyboardViewController

    @ObservedObject
    var model: KeyboardViewModel

    var body: some View {
        if !viewController.hasFullAccess {
            VStack {
                Text("The keyboard need **Full Access** to access the internet.")

                Button() {
                    openURL(URL(string: UIApplication.openSettingsURLString)!)
                } label: {
                    Text("Go to Settings")
                }
                .padding()
            }
            .padding()
            .background(Color.secondaryBackground)
            .cornerRadius(11)
            .padding()
        } else if let receivingMessage = receivingMessage {
            ReceivingResult(receivingMessage: receivingMessage, insert: insert, replace: replace) {
                self.receivingMessage = nil
            }
            .padding(.top)
        } else {
            VStack {
                HStack {
                    Text(model.usingText)
                        .lineLimit(1)

                    Spacer()

                    if let _ = model.preferredText {
                        Button {
                            model.preferredText = nil
                            Haptics.veryLight()
                        } label: {
                            Image(systemName: "rectangle.and.pencil.and.ellipsis")
                                .frame(width: 24, height: 24)
                        }
                    } else {
                        Button {
                            model.preferredText = UIPasteboard.general.string
                            Haptics.veryLight()
                        } label: {
                            Image(systemName: "list.clipboard")
                                .frame(width: 24, height: 24)
                        }
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color.secondaryBackground)
                .cornerRadius(11)
                .padding(.horizontal)
                .padding(.top)
                .padding(.bottom, 5)

                ChatSelector(text: model.usingText) { chat in
                    Task {
                        await send(for: chat)
                    }
                }
            }
        }
    }

    private func send(for chat: Chat) async {
        await chattingFeature.sendWithStream(content: model.selectedText, for: chat) {
            self.receivingMessage = messageFeature.createReceivingMessage(for: chat)

            return receivingMessage
        }
    }

    private func insert() {
        model.insert(receivingMessage?.content ?? "")
        Haptics.veryLight()
    }

    private func replace() {
        model.replace(receivingMessage?.content ?? "")
        Haptics.veryLight()
    }
}

private struct ChatSelector: View {
    let text: String

    let send: (Chat) -> Void

    @FetchRequest(
        sortDescriptors: [
            SortDescriptor(\.rawPinOrder, order: .reverse),
            SortDescriptor(\.rawUpdatedAt, order: .reverse)
        ]
    ) var chats: FetchedResults<Chat>

    private let gridLayout = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ScrollView {
                LazyVGrid(columns: gridLayout) {
                    ForEach(chats) { chat in
                        VStack {
                            chat.icon.image
                                .font(.title2)
                                .frame(width: 24, height: 24)
                                .padding(13)
                                .background(chat.uiColor)
                                .cornerRadius(8)
                                .colorScheme(.dark)

                            Text(chat.name)
                                .font(.caption)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity)
                        .onTapGesture {
                            send(chat)
                        }
                    }
                }
                .padding()
            }
            .frame(maxHeight: 200)
            .background(Color.secondaryBackground)
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
}

private struct ReceivingResult: View {
    @EnvironmentObject private var chattingFeature: ChattingFeature

    @ObservedObject var receivingMessage: Message

    let insert: () -> Void
    let replace: () -> Void
    let onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                if let chat = receivingMessage.chat {
                    chat.icon.image
                        .font(.footnote)
                        .frame(width: 12, height: 12)
                        .padding(5)
                        .background(chat.uiColor)
                        .cornerRadius(5)
                        .colorScheme(.dark)
                }

                Text(receivingMessage.chat?.name ?? "AssisChat")

                Spacer()

                Button {
                    onClose()
                } label: {
                    Image(systemName: "multiply")
                        .padding(10)
                        .background(Color.secondaryBackground)
                        .foregroundColor(.secondary)
                        .cornerRadius(.infinity)
                }
            }

            ScrollView {
                VStack(alignment: .leading) {
                    if let content = receivingMessage.content {
                        MessageContent(content: content)
                    } else if receivingMessage.receiving {
                        ProgressView()
                    } else if let reason = receivingMessage.failedReason {
                        Label(reason.localized, systemImage: "info.circle")
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 300, alignment: .leading)
            .padding(.vertical, 8)
            .padding(.horizontal, 15)
            .background(receivingMessage.failed ? Color.appRed : Color.secondaryBackground)
            .foregroundColor(receivingMessage.failed ? Color.white : Color.primary)
            .cornerRadius(15, corners: [.bottomRight, .topRight, .topLeft])

            HStack {
                Button() {
                    Task {
                        await chattingFeature.resendWithStream(receivingMessage: receivingMessage)
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .aspectRatio(1, contentMode: .fit)
                        .padding(10)
                        .background(Color.secondaryBackground)
                        .foregroundColor(.secondary)
                        .cornerRadius(.infinity)
                }

                Button(action: {
                    replace()
                }, label: {
                    Text("Replace")
                        .frame(maxWidth: .infinity)
                        .padding(10)
                        .background(Color.secondaryBackground)
                        .cornerRadius(.infinity)
                })
                .disabled(receivingMessage.receiving)

                Button(action: {
                    insert()
                }, label: {
                    Text("Insert")
                        .frame(maxWidth: .infinity)
                        .padding(10)
                        .background(Color.secondaryBackground)
                        .cornerRadius(.infinity)
                })
                .disabled(receivingMessage.receiving)
            }
        }
        .padding(.horizontal)
    }
}


struct KeyboardView_Previews: PreviewProvider {
    static var previews: some View {
        KeyboardView(viewController: .init(), model: KeyboardViewModel(insert: { _ in }, replace: { _ in }))
    }
}
