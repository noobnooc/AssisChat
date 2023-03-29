//
//  ProIntroductionView.swift
//  AssisChat
//
//  Created by Nooc on 2023-03-19.
//

import SwiftUI

struct ProIntroductionView: View {
    var body: some View {
        ScrollView {
            VStack {
                Image("Icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .cornerRadius(20)
                HStack {
                    Image(systemName: "laurel.leading")
                    Text("You are trying the Pro", comment: "")
                    Image(systemName: "laurel.trailing")
                }
                .font(.headline)
                .foregroundColor(.accentColor)
                .padding(.top)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 50)

            Text("By purchasing Pro, you will:")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.horizontal)
                .foregroundColor(.secondary)
                .font(.subheadline)
            HStack(alignment: .top) {
                Image(systemName: "heart")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)
                    .font(.largeTitle)
                    .foregroundColor(.appRed)

                VStack(alignment: .leading, spacing: 5) {
                    Text("Support Us")
                    Text("Your support is our driving force for moving forward.")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.secondaryGroupedBackground)
            .cornerRadius(12)
            .padding(.horizontal)

            HStack(alignment: .top) {
                Image(systemName: "icloud")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)
                    .font(.largeTitle)
                    .foregroundColor(.appBlue)

                VStack(alignment: .leading, spacing: 5) {
                    Text("iCloud Sync")
                    Text("Sync chats and messages across devices using iCloud.")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.secondaryGroupedBackground)
            .cornerRadius(12)
            .padding(.horizontal)

            HStack(alignment: .top) {
                Image(systemName: "doc.on.doc")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)
                    .font(.largeTitle)
                    .foregroundColor(.yellow)

                VStack(alignment: .leading, spacing: 5) {
                    Text("Auto Copy", comment: "Auto Copy feature title in pro introduction.")
                    Text("Auto copy the received message.", comment: "Auto Copy feature summary in pro introduction.")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.secondaryGroupedBackground)
            .cornerRadius(12)
            .padding(.horizontal)

            HStack(alignment: .top) {
                Image(systemName: "lock.open")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)
                    .font(.largeTitle)
                    .foregroundColor(.appGreen)

                VStack(alignment: .leading, spacing: 5) {
                    Text("Unlock All Features")
                    Text("Unlock all the local features of the app.")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.secondaryGroupedBackground)
            .cornerRadius(12)
            .padding(.horizontal)
        }
        .background(Color.groupedBackground)
    }
}

struct ProIntroductionView_Previews: PreviewProvider {
    static var previews: some View {
        ProIntroductionView()
    }
}
