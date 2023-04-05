//
//  ProIntroductionView.swift
//  AssisChat
//
//  Created by Nooc on 2023-03-19.
//

import SwiftUI
import StoreKit

struct ProIntroductionView: View {
    @EnvironmentObject private var proFeature: ProFeature

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
                    if proFeature.pro {
                        Text("Hey, Friend", comment: "The friends plan summary")
                    } else {
                        Text("You are trying the friends plan", comment: "The free trying plan summary")
                    }
                    Image(systemName: "laurel.trailing")
                }
                .font(proFeature.pro ? .title2 : .headline)
                .foregroundColor(proFeature.pro ? .accentColor : .primary)
                .padding(.top)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 50)

            if !proFeature.pro {
                BuyMeCoffee()
                    .padding()
            }

            if proFeature.pro {
                Text("You are in")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.horizontal)
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            } else {
                Text("Buy me any size of coffee, you will")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.horizontal)
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            }

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
                Image(systemName: "square.and.arrow.up")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)
                    .font(.largeTitle)
                    .foregroundColor(.yellow)

                VStack(alignment: .leading, spacing: 5) {
                    Text("Share Extension", comment: "Share Extension feature title in pro introduction.")
                    Text("Process text from other apps with Share Extension.", comment: "Share Extension feature summary in pro introduction.")
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

            CopyrightView()
                .padding(.vertical)
        }
        .background(Color.groupedBackground)
    }
}

private struct BuyMeCoffee: View {
    @EnvironmentObject private var proFeature: ProFeature

    @State private var selectedCoffee: Product?
    @State private var purchasing = false

    private var coffeeToPurchase: Product? {
        selectedCoffee ?? proFeature.defaultProduct
    }

    private let gridColumns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack {
            LazyVGrid(columns: gridColumns) {
                ForEach(proFeature.priceOrderedProducts) { product in
                    VStack {
                        Text(product.displayName)
                            .font(.footnote)
                            .lineLimit(2)
                            .foregroundColor(product == coffeeToPurchase ? .primary : .secondary)
                        Spacer()
                            .frame(minHeight: 10)
                        Text(product.displayPrice)
                            .bold()
                            .foregroundColor(product == coffeeToPurchase ? .accentColor : .primary)
                    }
                    .padding(.vertical)
                    .padding(.horizontal, 5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.secondaryGroupedBackground)
                    .cornerRadius(12)
                    .onTapGesture {
                        selectedCoffee = product
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(coffeeToPurchase == product ? Color.accentColor : Color.clear, lineWidth: 1)
                    )
                }
            }

            Text(coffeeToPurchase?.description ?? "Select A Size")
                .foregroundColor(.secondary)

            Button {
                Task {
                    purchasing = true
                    await purchase()
                    purchasing = true
                }
            } label: {
                Text("Good Luck", comment: "The buying button in pro introduction")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(15)
                    .foregroundColor(.white)
            }
            .disabled(purchasing)

            Button("Restore Purchase") {
                proFeature.prepareAndRestore()
            }
        }
    }


    @MainActor
    func purchase() async {
        guard let coffeeToPurchase = coffeeToPurchase else { return }

        do {
            try await proFeature.purchase(coffeeToPurchase)
        } catch {
            print("Failed coffee purchase: \(error)")
        }
    }
}

struct ProIntroductionView_Previews: PreviewProvider {
    static var previews: some View {
        ProIntroductionView()
    }
}
