//
//  KeyboardExtensionConfigIntroduction.swift
//  AssisChat
//
//  Created by Nooc on 2023-05-31.
//

import SwiftUI

struct KeyboardExtensionConfigIntroduction: View {
    @Environment(\.openURL) private var openURL

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
                    Text("Open **Settings** for **AssisChat**.")
                    Button {
                        #if os(iOS)
                        openURL(URL(string: UIApplication.openSettingsURLString)!)
                        #endif
                    } label: {
                        Text("Go To **Settings**")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.secondaryGroupedBackground)
                            .cornerRadius(11)
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text(String("2."))
                        .font(.largeTitle)
                        .bold()
                        .italic()
                        .foregroundColor(Color.accentColor)
                    +
                    Text("In **PREFERRED LANGUAGE** section, select **Keyboards**.")
                }


                VStack(alignment: .leading, spacing: 10) {
                    Text(String("3."))
                        .font(.largeTitle)
                        .bold()
                        .italic()
                        .foregroundColor(Color.accentColor)
                    +
                    Text("Checked both **AssisChat** and **Allow Full Access**.")
                }
            }
            .padding()
        }
        .background(Color.groupedBackground)
        .navigationTitle("Setup Keyboard Extension")
    }
}

struct KeyboardExtensionConfigIntroduction_Previews: PreviewProvider {
    static var previews: some View {
        KeyboardExtensionConfigIntroduction()
    }
}
