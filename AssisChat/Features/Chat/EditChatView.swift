//
//  EditChatView.swift
//  AssisChat
//
//  Created by Nooc on 2023-03-07.
//

import SwiftUI

struct EditChatView: View {
    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject private var chatFeature: ChatFeature

    @ObservedObject var chat: Chat
    @StateObject private var model: ChatEditorModel

    init(chat: Chat) {
        self.chat = chat
        self._model = StateObject(wrappedValue: ChatEditorModel(chat: chat))
    }

    var body: some View {
        ChatEditor(model: model) {
            #if os(iOS)
            Section {
                Button {
                    update()
                    dismiss()
                } label: {
                    Text("CHAT_UPDATE")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.primary)
                        .colorScheme(.dark)
                }
                .disabled(!model.available)
                .listRowInsets(EdgeInsets())
            }

            Section {
                Button {
                    dismiss()
                } label: {
                    Text("CANCEL")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .listRowInsets(EdgeInsets())
            }
            #endif
        }
        .toolbar {
#if os(iOS)
            ToolbarItem(placement: .navigationBarLeading) {
                Button("CANCEL") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button("CHAT_UPDATE_SHORT") {
                    update()
                    dismiss()
                }
                .disabled(!model.available)
                .buttonStyle(.borderedProminent)
            }
#else
            ToolbarItem {
                Button("CHAT_UPDATE_SHORT") {
                    update()
                    dismiss()
                }
                .disabled(!model.available)
                .buttonStyle(.borderedProminent)
            }
            ToolbarItem {
                Button("CANCEL") {
                    dismiss()
                }
            }
#endif

        }
    }

    func update() {
        let plainChat = model.plain

        guard plainChat.available else { return }

        chatFeature.updateChat(plainChat, for: chat)
    }
}

struct EditChatView_Previews: PreviewProvider {
    static var previews: some View {
        EditChatView(chat: .init())
    }
}
