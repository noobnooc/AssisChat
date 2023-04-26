//
//  Clipboard.swift
//  AssisChat
//
//  Created by Nooc on 2023-04-19.
//

import Foundation

#if os(iOS)
import UIKit
#else
import AppKit
#endif

struct Clipboard {
    static func copyToClipboard(text: String) {
#if os(iOS)
        UIPasteboard.general.string = text
#else
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(text, forType: .string)
#endif

        Haptics.veryLight()
    }
}
