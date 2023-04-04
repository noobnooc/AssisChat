//
//  View+Extensions.swift
//  AssisChat
//
//  Created by Nooc on 2023-03-06.
//

import Foundation
import SwiftUI

#if os(iOS)
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCornerRectangle(radius: radius, corners: corners) )
    }
}

struct RoundedCornerRectangle: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
#endif

extension View {
    func inlineNavigationBar() -> some View {
        #if os(iOS)
        self.navigationBarTitleDisplayMode(.inline)
        #else
        self
        #endif
    }
}

extension View {
    func overlayGeometryReader() -> some View {
        self
            .overlay(
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: ViewHeightKey.self, value: proxy.size.height)
                }
            )
    }
}

struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

