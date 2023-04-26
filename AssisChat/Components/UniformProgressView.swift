//
//  UniformProgressView.swift
//  AssisChat
//
//  Created by Nooc on 2023-04-24.
//

import SwiftUI

struct UniformProgressView: View {
    var body: some View {
        ProgressView()
        #if os(macOS)
            .frame(width: 16, height: 16)
            .scaleEffect(0.5)
        #endif
    }
}

struct UniformProgressView_Previews: PreviewProvider {
    static var previews: some View {
        UniformProgressView()
    }
}
