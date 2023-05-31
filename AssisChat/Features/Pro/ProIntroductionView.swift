//
//  ProIntroductionView.swift
//  AssisChat
//
//  Created by Nooc on 2023-03-19.
//

import SwiftUI
import StoreKit

struct ProIntroductionView: View {
    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject private var proFeature: ProFeature

    var body: some View {
        ZStack(alignment: .topTrailing) {
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
                            Text("Hey, Friend", comment: "The coffee plan summary")
                        } else {
                            Text("You are trying the Coffee plan", comment: "The free trying plan summary")
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
                    if proFeature.isRunningInTestFlight {
                        TestFlightPrompt()
                            .padding()
                    } else {
                        BuyMeCoffee()
                            .padding()
                    }
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
                        .padding(.top, 30)
                }

                ProFeatureList()

                CopyrightView()
                    .padding(.vertical)
            }

            #if os(macOS)
            Button {
                dismiss()
            } label: {
                Image(systemName: "multiply")
            }
            .buttonBorderShape(.roundedRectangle)
            .padding()
            #endif
        }
        .background(Color.groupedBackground)
    }
}

struct ProFeatureList: View {
    var body: some View {
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

        HStack(alignment: .top) {
            Image(systemName: "lock.slash")
                .resizable()
                .scaledToFit()
                .frame(width: 36, height: 36)
                .font(.largeTitle)
                .foregroundColor(.appRed)

            VStack(alignment: .leading, spacing: 5) {
                Text("NOT Include Services")
                Text("The Coffee Plan does NOT include OpenAI API services and any online services that AssisChat may offer in the future.")
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
}

private struct TestFlightPrompt: View {
    var body: some View {
        VStack {
            Image(systemName: "heart")
                .resizable()
                .scaledToFit()
                .frame(width: 36, height: 36)
                .font(.largeTitle)
                .foregroundColor(.appRed)

            Text("You are using the TestFlight version. Please download the app from AppStore and buy me a coffee to support me.")
        }
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
                    VStack(spacing: 0) {
                        Text(product.displayName)
                            .font(.footnote)
                            .lineLimit(2)
                            .foregroundColor(product == coffeeToPurchase ? .primary : .secondary)
                        if proFeature.limitedTimeCoffeeIds.contains(product.id) {
                            Text("Limited-time", comment: "The limited-time label text for coffee products")
                                .padding(2)
                                .background(Color.appRed)
                                .colorScheme(.dark)
                                .cornerRadius(2)
                                .font(.footnote)
                            Spacer()
                        } else {
                            Spacer()
                                .frame(minHeight: 10)
                        }
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
                        Haptics.veryLight()
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
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
                    purchasing = false
                }
            } label: {
                HStack {
                    if purchasing {
                        UniformProgressView()
                            .padding(.horizontal, 5)
                    }

                    Text("Good Luck", comment: "The buying button in pro introduction")
                }
                .frame(maxWidth: .infinity)
#if os(iOS)
                .padding()
                .background(Color.accentColor)
                .cornerRadius(15)
                .foregroundColor(.white)
#endif
            }
            #if os(macOS)
            .buttonStyle(.borderedProminent)
            #endif
            .disabled(purchasing)

            Button("Restore Purchase") {
                proFeature.prepareAndRestore()
            }
        }
        .task {
            proFeature.prepareAndRestore()
        }
    }


    @MainActor
    func purchase() async {
        guard let coffeeToPurchase = coffeeToPurchase else { return }

        do {
            _ = try await proFeature.purchase(coffeeToPurchase)
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
