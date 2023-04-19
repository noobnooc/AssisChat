//
//  Clipboard.swift
//  AssisChat
//
//  Created by Nooc on 2023-04-19.
//

import Foundation
import UIKit

struct Clipboard {
    static func copyToClipboard(text: String) {
#if os(iOS)
        UIPasteboard.general.string = text
#endif

        Haptics.veryLight()
    }
}
