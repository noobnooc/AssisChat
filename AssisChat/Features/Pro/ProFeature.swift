//
//  ProFeature.swift
//  AssisChat
//
//  Created by Nooc on 2023-03-18.
//

import Foundation
import StoreKit
import SwiftUI

class ProFeature: ObservableObject {
    let coffeeIds: Set<String> = [
        "assischat_coffee_small",
        "assischat_coffee_medium",
        "assischat_coffee_large"
    ]

    let limitedTimeCoffeeIds: Set<String> = [
        "assischat_coffee_small"
    ]

    @Published private(set) var coffeeProducts: [Product] = []
    @Published private(set) var purchasedCoffeeProducts: [Product] = [] {
        didSet {
            pro = !purchasedCoffeeProducts.isEmpty
        }
    }

    @AppStorage(SharedUserDefaults.proKey, store: SharedUserDefaults.shared)
    private(set) var pro = false

    var priceOrderedProducts: [Product] {
        coffeeProducts.sorted { p1, p2 in p1.price < p2.price }
    }

    var defaultProduct: Product? {
        coffeeProducts.first { product in product.id == "assischat_coffee_medium"}
    }

    var largestPurchasedProProduct: Product? {
        return purchasedCoffeeProducts.sorted { p1, p2 in
            p1.price < p2.price
        }
        .last
    }

    var showBadge: Bool  {
        false
    }

    var isRunningInTestFlight: Bool {
        guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL else {
            return false
        }

        return appStoreReceiptURL.lastPathComponent == "sandboxReceipt"
    }

    private var updateListenerTask: Task<Void, Error>? = nil

    init() {
        //Start a transaction listener as close to app launch as possible so you don't miss any transactions.
        updateListenerTask = listenForTransactions()

        prepareAndRestore()
    }

    deinit {
        updateListenerTask?.cancel()
    }

    func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            //Iterate through any transactions that don't come from a direct call to `purchase()`.
            for await result in Transaction.updates {
                guard case .verified(let transaction) = result else {
                    return
                }

                //Deliver products to the user.
                await self.updateCustomerProductStatus()

                //Always finish a transaction.
                await transaction.finish()
            }
        }
    }

    func purchase(_ product: Product) async throws -> StoreKit.Transaction? {
        //Begin purchasing the `Product` the user selects.
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            guard case .verified(let transaction) = verification else {
                return nil
            }

            //The transaction is verified. Deliver content to the user.
            await updateCustomerProductStatus()

            //Always finish a transaction.
            await transaction.finish()

            return transaction
        case .userCancelled, .pending:
            return nil
        default:
            return nil
        }
    }

    func prepareAndRestore() {
        Task {
            await fetchProducts()
            await updateCustomerProductStatus()
        }
    }

    @MainActor
    func fetchProducts() async {
        do {
            coffeeProducts = try await Product.products(for: coffeeIds)
        } catch {
            print("Error fetching products: \(error.localizedDescription)")
        }
    }

    @MainActor
    func updateCustomerProductStatus() async {
        for await result in Transaction.currentEntitlements {
            do {
                guard case .verified(let transaction) = result else { return }

                guard let purchasedCoffee = coffeeProducts.first(where: { $0.id == transaction.productID }) else {
                    return
                }

                purchasedCoffeeProducts.append(purchasedCoffee)
            }
        }
    }
}
