//
//  ShareView.swift
//  Share
//
//  Created by Nooc on 2023-03-31.
//

import SwiftUI

struct ShareView: View {
    @EnvironmentObject private var messageFeature: MessageFeature
    @EnvironmentObject private var chattingFeature: ChattingFeature

    let sharedText: String
    let complete: () -> Void
    let cancel: () -> Void

    @State private var receivingMessage: Message?

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()

                VStack {
                    if let receivingMessage = receivingMessage {
                        ReceivingResult(receivingMessage: receivingMessage) {
                            complete()
                        }
                    } else {
                        ChatSelector(sharedText: sharedText, cancel: cancel) { chat in
                            Task {
                                await send(for: chat)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .background(Color.background)
                .cornerRadius(20)
                .padding(.horizontal, 10)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }

    private func send(for chat: Chat) async {
        self.receivingMessage = await chattingFeature.sendWithStream(content: sharedText, to: chat)
    }
}

private struct ChatSelector: View {
    let sharedText: String
    let cancel: () -> Void
    let send: (Chat) -> Void

    @State private var scrollViewHeight: CGFloat = 0

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
            Text("Send to chat")
            Text(sharedText)
                .foregroundColor(.secondary)
                .font(.footnote)
                .lineLimit(2)

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
                .overlayGeometryReader()
            }
            .onPreferenceChange(ViewHeightKey.self) { height in
                scrollViewHeight = height
            }
            .frame(maxHeight: scrollViewHeight)
            .background(Color.secondaryBackground)
            .cornerRadius(12)

            Button(action: {
                cancel()
            }, label: {
                Text("Cancel")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.secondaryBackground)
                    .cornerRadius(12)
            })
        }
        .padding()
    }
}

private struct ReceivingResult: View {
    @EnvironmentObject private var chattingFeature: ChattingFeature

    @State private var scrollViewHeight: CGFloat = 0
    @ObservedObject var receivingMessage: Message

    let complete: () -> Void

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
                    complete()
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
                .overlayGeometryReader()
            }
            .onPreferenceChange(ViewHeightKey.self) { height in
                scrollViewHeight = height
            }
            .frame(maxWidth: .infinity, maxHeight: scrollViewHeight, alignment: .leading)
            .padding(.vertical, 8)
            .padding(.horizontal, 15)
            .background(receivingMessage.failed ? Color.appRed : Color.secondaryBackground)
            .foregroundColor(receivingMessage.failed ? Color.white : Color.primary)
            #if os(iOS)
            .cornerRadius(15, corners: [.bottomRight, .topRight, .topLeft])
            #endif

            HStack {
                Button(action: {
                    Task {
                        await chattingFeature.resendWithStream(receivingMessage: receivingMessage)
                    }
                }, label: {
                    Text("Regenerate")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.background)
                        .cornerRadius(20)
                        .padding(.horizontal, 10)
                })
                .disabled(receivingMessage.receiving)

                Button(action: {
                    receivingMessage.copyToPasteboard()
                    complete()
                }, label: {
                    Text("Copy & Close")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.background)
                        .cornerRadius(20)
                        .padding(.horizontal, 10)
                })
                .disabled(receivingMessage.receiving)
            }
        }
        .padding()
    }
}

struct ShareView_Previews: PreviewProvider {
    static var previews: some View {
        ShareView(sharedText: "Example text") {

        } cancel: {

        }
    }
}
