//
//  KeyboardExtensionIntroduction.swift
//  AssisChat
//
//  Created by Nooc on 2023-05-31.
//

import SwiftUI

struct KeyboardExtensionIntroduction: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                NavigationLink {
                    KeyboardExtensionConfigIntroduction()
                } label: {
                    HStack(alignment: .top) {
                        Image(systemName: "gearshape")
                            .foregroundColor(.accentColor)

                        Text("Please config in **Settings** before using **Keyboard Extension**")
                            .multilineTextAlignment(.leading)
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding()
                    .background(Color.secondaryGroupedBackground)
                    .cornerRadius(11)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text(String("1."))
                        .font(.largeTitle)
                        .bold()
                        .italic()
                        .foregroundColor(Color.accentColor)
                    +
                    Text("Input text in text field and select the text want to be handled.")
                    Image("KeyboardExtensionInput")
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
                    Text("Click the **Globe** icon to switch the keyboard to **AssisChat**.")
                    Image("KeyboardExtensionSwitchKeyboard")
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
                    Image("KeyboardExtensionSelectChat")
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
                    Text("When the result has completed, click the **Replace** button to replace the selected text in the text field with the chat result.")
                    Image("KeyboardExtensionResult")
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(11)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text(String("5."))
                        .font(.largeTitle)
                        .bold()
                        .italic()
                        .foregroundColor(Color.accentColor)
                    +
                    Text("Then the text field has replaced with handled text.")
                    Image("KeyboardExtensionReplaced")
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(11)
                }
            }
            .padding()
        }
        .background(Color.groupedBackground)
        .navigationTitle("Using Keyboard Extension")
    }
}

struct KeyboardExtensionIntroduction_Previews: PreviewProvider {
    static var previews: some View {
        KeyboardExtensionIntroduction()
    }
}
