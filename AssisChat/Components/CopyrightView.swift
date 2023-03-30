//
//  CopyrightView.swift
//  AssisChat
//
//  Created by Nooc on 2023-03-06.
//

import SwiftUI

struct CopyrightView: View {
    let detailed: Bool

    init(detailed: Bool = false) {
        self.detailed = detailed
    }

    var body: some View {
        VStack(alignment: .center) {
            if detailed {
                Text("Current Version: \(Bundle.main.releaseVersionNumber ?? "")(\(Bundle.main.buildVersionNumber ?? ""))")
                    .font(.system(.footnote))
                Text(String("Crafted by Nooc(@noobnooc)"))
                    .font(.system(.footnote))
                    .padding(.bottom)
            }

            Image("NoocAvatarTemplate")
                .resizable()
                .scaledToFit()
                .frame(width: 20)
        }
        .frame(maxWidth: .infinity)
        .foregroundColor(.secondary)
        .listRowBackground(Color.clear)
        .opacity(0.5)
    }

}

struct CopyrightView_Previews: PreviewProvider {
    static var previews: some View {
        CopyrightView()
    }
}
