//
//  SelectChatHintView.swift
//  AssisChat
//
//  Created by Nooc on 2023-03-08.
//

import SwiftUI

struct SelectChatHintView: View {
    var body: some View {
        VStack {
            Image(systemName: "bubble.left")
                .resizable()
                .scaledToFit()
                .frame(width: 80)
                .symbolVariant(.square)
                .foregroundColor(.secondary)

            Text("CHATTING_SELECT_CHAT_HINT")
                .foregroundColor(.secondary)
                .font(.subheadline)
                .padding(.top)
        }
    }
}

struct SelectChatHintView_Previews: PreviewProvider {
    static var previews: some View {
        SelectChatHintView()
    }
}
