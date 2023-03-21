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
                Text("You are trying the Pro", comment: "")
                    .padding(.top)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 50)

            Text("By purchasing Pro, you will:")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.horizontal)
                .foregroundColor(.secondary)
            HStack(alignment: .top) {
                Image(systemName: "heart")
                    .font(.largeTitle)
                    .foregroundColor(.appRed)

                VStack(alignment: .leading) {
                    Text("Support Us")
                    Text("Your support is our driving force for moving forward.")
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.secondaryGroupedBackground)
            .cornerRadius(12)
            .padding(.horizontal)

            HStack(alignment: .top) {
                Image(systemName: "lock.open")
                    .font(.largeTitle)
                    .foregroundColor(.appGreen)

                VStack(alignment: .leading) {
                    Text("Unlock All Features")
                    Text("Unlock all the local features of the app.")
                        .foregroundColor(.secondary)
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
