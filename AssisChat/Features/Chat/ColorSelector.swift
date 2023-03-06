//
//  ColorSelector.swift
//  AssisChat
//
//  Created by Nooc on 2023-03-05.
//

import SwiftUI

struct ColorSelector: View {
    static let blockSize: CGFloat = 30
    static let indicatorSize: CGFloat = 15

    @Binding var selection: Chat.Color?

    private var colorPickSelection: Binding<Color> {
        Binding {
            selection?.color ?? Chat.Color.default.color
        } set: { updatedColor in
            selection = .custom(color: updatedColor)
        }
    }

    private let gridLayout = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]

    var body: some View {
        LazyVGrid(columns: gridLayout) {
            ForEach(Chat.Color.builtIns, id: \.rawValue) { chatColor in
                chatColor.color
                    .frame(width: Self.blockSize, height: Self.blockSize)
                    .cornerRadius(Self.blockSize)
                    .overlay(alignment: .center) {
                        Color.white
                            .frame(width: Self.indicatorSize, height: Self.indicatorSize)
                            .cornerRadius(Self.indicatorSize)
                            .opacity(chatColor == selection ? 1 : 0)
                    }
                    .onTapGesture {
                        if selection == chatColor {
                            selection = nil
                        } else {
                            selection = chatColor
                        }

                        Haptics.veryLight()
                    }
            }
        }
    }
}

struct ColorSelector_Previews: PreviewProvider {
    static var previews: some View {
        ColorSelector(selection: .constant(nil))
    }
}
