//
//  ChatIconSelector.swift
//  AssisChat
//
//  Created by Nooc on 2023-03-05.
//

import SwiftUI

struct ChatIconSelector: View {
    @Binding var selection: Chat.Icon

    static private let selectorGridLayout = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]

    var body: some View {
        List {
            Section("CHAT_EDITOR_ICON_SELECTOR_ICON") {
                LazyVGrid(columns: Self.selectorGridLayout) {
                    ForEach(Chat.Icon.symbols) { symbol in
                        let selected = symbol == selection

                        symbol.image
                            .frame(width: 22, height: 22)
                            .padding(10)
                            .foregroundColor(selected ? .secondaryGroupedBackground : .primary)
                            .background(selected ? Color.primary : Color.secondaryGroupedBackground)
                            .cornerRadius(10)
                        // To ensure whole icon clickable
                            .clipShape(Rectangle())
                            .onTapGesture {
                                selection = symbol
                                Haptics.veryLight()
                            }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
#if os(iOS)
        .listStyle(.insetGrouped)
#endif
    }
}

struct ChatIconSelector_Previews: PreviewProvider {
    static var previews: some View {
        ChatIconSelector(selection: .constant(.default))
    }
}
