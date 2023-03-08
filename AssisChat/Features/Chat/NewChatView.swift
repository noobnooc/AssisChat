//
//  NewChatView.swift
//  AssisChat
//
//  Created by Nooc on 2023-03-05.
//

import SwiftUI


struct NewChatView: View {
    @Environment(\.dismiss) var dismiss

    @EnvironmentObject var chatFeature: ChatFeature

    @StateObject var model: ChatEditorModel = ChatEditorModel(
        name: "",
        temperature: .balanced,
        systemMessage: "",
        isolated: false,
        messagePrefix: "",
        autoCopy: false,
        icon: .default,
        color: .default
    )

    var body: some View {
        ChatEditor(model: model) {
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
                #if os(macOS)
                .buttonStyle(.plain)
                .cornerRadius(15)
                #endif
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
        }
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .navigationBarLeading) {
                Button("CANCEL") {
                    dismiss()
                }
            }

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
        NewChatView()
    }
}
