//
//  NewChatView.swift
//  AssisChat
//
//  Created by Nooc on 2023-03-05.
//

import SwiftUI


struct CustomNewChatView: View {
    @EnvironmentObject private var chatFeature: ChatFeature

    let dismiss: () -> Void

    @StateObject private var model: ChatEditorModel = ChatEditorModel(
        name: "",
        temperature: .balanced,
        systemMessage: "",
        historyLengthToSend: .defaultHistoryLengthToSend,
        messagePrefix: "",
        autoCopy: false,
        icon: .default,
        color: .default,
        model: Chat.OpenAIModel.default.rawValue
    )

    var body: some View {
        ChatEditor(model: model) {
            #if os(iOS)
            Section {
                Button {
                    create()
                    dismiss()
                } label: {
                    Text("CHAT_CREATE")
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
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("CHAT_CREATE_SHORT") {
                    create()
                    dismiss()
                }
                .disabled(!model.available)
                .buttonStyle(.borderedProminent)
            }
            #else
            ToolbarItem {
                Button("CHAT_CREATE_SHORT") {
                    create()
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

    func create() {
        let plainChat = model.plain

        guard plainChat.available else { return }

        chatFeature.createChat(plainChat)
    }

}

struct NewChatView_Previews: PreviewProvider {
    static var previews: some View {
        CustomNewChatView() {
            
        }
    }
}
