//
//  ProFeature.swift
//  AssisChat
//
//  Created by Nooc on 2023-03-18.
//

import Foundation

class ProFeature: ObservableObject {
    let pro = true

    var showBadge: Bool  {
        !pro
    }
}
