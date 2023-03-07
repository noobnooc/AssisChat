//
//  ChatDetailView.swift
//  AssisChat
//
//  Created by Nooc on 2023-03-07.
//

import SwiftUI

struct ChatDetailView: View {
    @EnvironmentObject private var chatFeature: ChatFeature

    @ObservedObject var chat: Chat

    @State private var editing = false

    var body: some View {
        List {
            Section {
                VStack {
                    chat.icon.image
                        .font(.title2)
                        .frame(width: 50, height: 50)
                        .background(chat.uiColor)
                        .colorScheme(.dark)
                        .cornerRadius(12)

                    Text(chat.name)

                    HStack {
                        Text(chat.temperature.display)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .background(chat.temperature.color)
                            .cornerRadius(.infinity)

                        if chat.isolated {
                            Text("Isolated")
                                .padding(.vertical, 5)
                                .padding(.horizontal, 10)
                                .background(Color.appRed)
                                .cornerRadius(.infinity)
                        }
                    }
                    .font(.subheadline)
                    .colorScheme(.dark)
                    .padding(.top)
                }
                .frame(maxWidth: .infinity)
            }
            .listRowBackground(Color.clear)

            if let systemMessage = chat.systemMessage {
                Section("Role Prompt") {
                    Text(systemMessage)
                        .foregroundColor(Color.secondary)
                }
            }

            if chat.messagePrefix != nil {
                Section("Config") {
                    if let messagePrefix = chat.messagePrefix {
                        VStack(alignment: .leading) {
                            Text("Message Prefix")
                                .font(.footnote)
                                .foregroundColor(Color.secondary)
                            
                            Text(messagePrefix)
                                .padding(.top, 5)
                        }
                    }
                }
            }
        }
        .toolbar {
            Menu {
                Button {
                    editing = true
                } label: {
                    Label("Edit", systemImage: "pencil")
                }

                Button {
                    chatFeature.clearMessages(for: chat)
                } label: {
                    Label("Clear Messages", systemImage: "eraser.line.dashed")
                }
            } label: {
                Label("Actions", systemImage: "ellipsis")
            }
        }
        .sheet(isPresented: $editing) {
            NavigationView {
                EditChatView(chat: chat)
                    .navigationTitle("Edit Chat")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

struct ChatDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ChatDetailView(chat: .init())
    }
}
