//
//  ProductDataService.swift
//  SwipePro
//
//  Created by Rahul Rai on 22/11/24.
//

import Foundation
import Combine

class ProductDataService {
    @Published var allProducts: [Product] = []
    
    var productSubscription: AnyCancellable?
    private var favoriteProductIds: Set<Int> = []
    
    init(){
        print("ProductDataService initialized")
        loadFavoriteProductIds()
        getProducts()
    }
    
    func getProducts(){
        guard let url = URL(string: "https://app.getswipe.in/api/public/get") else { return }
        
        productSubscription = URLSession.shared.dataTaskPublisher(for: url)
            .subscribe(on: DispatchQueue.global(qos: .default))
            .tryMap{ (output) -> Data in
                guard let response = output.response as? HTTPURLResponse, response.statusCode >= 200 && response.statusCode < 300 else {
                    throw URLError(.badServerResponse)
                }
//                print("Data received")
//                print(output.data)
                return output.data
            }
            .receive(on: DispatchQueue.main)
            .decode(type: [Product].self, decoder: JSONDecoder())
            .sink { (completion) in
                switch completion{
                case .finished:
                    break
                case .failure(let error):
//                    print(completion)
//                    print("here")/
                    print(error.localizedDescription)
//                    print("hi")
                }
            } receiveValue: {[weak self] (returnedProducts) in
//                print(returnedProducts)
//                self?.updateFavoritesInProducts(products: returnedProducts)
//                self?.allProducts = returnedProducts
////                self?.allProducts = self?.updateFavoritesInProducts(products: returnedProducts) ?? []
//                self?.productSubscription?.cancel()
                
                
                guard let self = self else { return }
                    
                    // Create a mutable copy of the returned products
                    var mutableProducts = returnedProducts
                    
                    // Update the favorites in the mutable copy
                    self.updateFavoritesInProducts(products: &mutableProducts)
                    print("🤪Before printing products")
                print(mutableProducts)
                    print("🤪After printing products")
                    // Assign the updated products back to the published property
                    self.allProducts = mutableProducts
                    
                    self.productSubscription?.cancel()
            }
    }
    
    private func updateFavoritesInProducts(products: inout [Product]) {
        for favHash in favoriteProductIds {
            if let index = products.firstIndex(where: { $0.hashValue == favHash }) {
                print("🤩 \(products[index].productName) is a favorite")
                products[index].isFavorite = true
            }
        }
    }

    
    func toggleFavorite(product: Product) {
        let productHash = product.hashValue
        if let index = allProducts.firstIndex(where: { $0.hashValue == productHash }) {
            print("Toggling favorite for \(allProducts[index].productName)")
            allProducts[index].isFavorite.toggle()

            if allProducts[index].isFavorite {
                print("😄 Adding \(productHash) to favorites")
                favoriteProductIds.insert(productHash)
            } else {
                print("😢 Removing \(productHash) from favorites")
                favoriteProductIds.remove(productHash)
            }

            // Persist favorites
            saveFavoriteProductIds()
            print("Favorite product hashes: \(favoriteProductIds)")
        }
    }

    
    private func saveFavoriteProductIds() {
        UserDefaults.standard.set(Array(favoriteProductIds), forKey: "favoriteProductIds")
    }

    private func loadFavoriteProductIds() {
        if let savedIds = UserDefaults.standard.object(forKey: "favoriteProductIds") as? [Int] {
            favoriteProductIds = Set(savedIds)
        }
    }

    
    
    
    
//
//    private func updateFavoritesInProducts(products: inout [Product]) {
//        for fav in favoriteProductIds {
//            if let index = products.firstIndex(where: { $0.id.uuidString == fav }) {
//                print("\(fav) is a favorite")
//                print("🤩\(products[index].id.uuidString) is a favorite. Product name is \(products[index].productName)")
//                products[index].isFavorite = true
//                
//            }
//        }
//    }
//
//
//     func toggleFavorite(product: Product) {
//       if let index = allProducts.firstIndex(where: { $0.id == product.id }) {
//         print("Toggling favorite")
//         allProducts[index].isFavorite.toggle()
//
//         if allProducts[index].isFavorite {
//             print("😄Adding \(product.id.uuidString) to favorites")
//             favoriteProductIds.insert(product.id.uuidString)
//         } else {
//                print("😢Removing \(product.id.uuidString) from favorites")
//             favoriteProductIds.remove(product.id.uuidString)
//         }
//         saveFavoriteProductIds()
//        print("Favorite product IDs:")
//        print(favoriteProductIds)
//    
//       }
//     }
//
//     // Load favorite product IDs from UserDefaults
//     private func loadFavoriteProductIds() {
//       if let savedIds = UserDefaults.standard.object(forKey: "favoriteProductIds") as? [String] {
//         favoriteProductIds = Set(savedIds)
//       }
//     }
//
//     // Save favorite product IDs to UserDefaults
//     private func saveFavoriteProductIds() {
//       UserDefaults.standard.set(Array(favoriteProductIds), forKey: "favoriteProductIds")
//     }
}

