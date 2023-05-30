//
//  KeyboardViewModel.swift
//  Keyboard
//
//  Created by Nooc on 2023-05-29.
//

import Foundation
import UIKit

class KeyboardViewModel: ObservableObject {
    @Published var selectedText: String = ""
    @Published var preferredText: String?

    let insert: (_ text: String) -> Void
    let replace: (_ text: String) -> Void

    var usingText: String {
        return preferredText ?? selectedText
    }

    init(insert: @escaping (_ text: String) -> Void, replace: @escaping (_ text: String) -> Void) {
        self.insert = insert
        self.replace = replace
    }
}
