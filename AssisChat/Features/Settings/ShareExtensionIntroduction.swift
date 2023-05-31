//
//  SettingsShareExtensionFeatureIntroduction.swift
//  AssisChat
//
//  Created by Nooc on 2023-05-31.
//

import SwiftUI

struct ShareExtensionIntroduction: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(String("1."))
                        .font(.largeTitle)
                        .bold()
                        .italic()
                        .foregroundColor(Color.accentColor)
                    +
                    Text("Select text from other apps, select **Share** item in context menu.")
                    Image("ShareExtensionContextMenu")
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(11)

                }

                VStack(alignment: .leading, spacing: 10) {
                    Text(String("2."))
                        .font(.largeTitle)
                        .bold()
                        .italic()
                        .foregroundColor(Color.accentColor)
                    +
                    Text("Select **AssisChat** in share menu.")
                    Image("ShareExtensionShareMenu")
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(11)
                }


                VStack(alignment: .leading, spacing: 10) {
                    Text(String("3."))
                        .font(.largeTitle)
                        .bold()
                        .italic()
                        .foregroundColor(Color.accentColor)
                    +
                    Text("Select a chat to handle the text.")
                    Image("ShareExtensionChatSelect")
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(11)
                }


                VStack(alignment: .leading, spacing: 10) {
                    Text(String("4."))
                        .font(.largeTitle)
                        .bold()
                        .italic()
                        .foregroundColor(Color.accentColor)
                    +
                    Text("Then you can see the result, regenerate the result, or copy the result text.")
                    Image("ShareExtensionResult")
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(11)
                }
            }
            .padding()
        }
        .background(Color.groupedBackground)
        .navigationTitle("Using Share Extension")
    }
}

struct SettingsShareExtensionFeatureIntroduction_Previews: PreviewProvider {
    static var previews: some View {
        ShareExtensionIntroduction()
    }
}
