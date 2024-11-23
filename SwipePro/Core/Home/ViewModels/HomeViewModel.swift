//
//  HomeViewModel.swift
//  SwipePro
//
//  Created by Rahul Rai on 22/11/24.
//

import Foundation
import Combine
import SwiftUI


class HomeViewModel : ObservableObject {
//    @Published var allProducts:
    @Published var allProducts: [Product] = []
    
    @Published var searchText: String = ""
    @Published var sortOption: SortOption = .favorite
    
    private let dataService = ProductDataService()
    private var cancellables = Set<AnyCancellable>()
    
    
    enum SortOption {
        case favorite
    }
    

    
    init(){
        addSubscribers()
    }
    
    private func sortProductsByOption(sort: SortOption, products: [Product]) -> [Product] {
        switch sort{
        case .favorite:
            return products.sorted { $0.isFavorite && !$1.isFavorite }
        }
    }
    
    
    private func filterAndSortCoinsByFavorite(text: String, product: [Product], sort: SortOption ) -> [Product] {
        var filteredCoins = filterCoins(text: text, product: product)

        filteredCoins = sortProductsByOption(sort: sort, products: filteredCoins)
        return filteredCoins
    }
        
    
    private func filterCoins(text: String, product: [Product]) -> [Product] {
        guard !text.isEmpty else {
            return product
        }
        let lowercasedText = text.lowercased()
        return product.filter { (product) -> Bool in
            return (product.productName.lowercased().contains(lowercasedText)) || product.productType.lowercased().contains(lowercasedText)
        }
    }
    
    
    func addSubscribers(){
//        dataService.$allProducts
//            .sink { [weak self] (returnedProducts) in
//                self?.allProducts = returnedProducts
//            }
//            .store(in: &cancellables)
        
        $searchText
            .combineLatest(dataService.$allProducts, $sortOption)
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)

            .map(filterAndSortCoinsByFavorite)
//            .map { (text, startingProducts) -> [Product] in
//                guard !text.isEmpty else {
//                    return startingProducts
//                }
//                let lowercasedText = text.lowercased()
//                let filteredProducts = startingProducts.filter { (product) -> Bool in
//                    return (product.productName.lowercased().contains(lowercasedText)) || product.productType.lowercased().contains(lowercasedText)
//                }
//                return filteredProducts
////                return self.sortProductsByFavorite(products: filteredProducts)
//            }
            .sink { [weak self] (returnedProducts) in
                self?.allProducts = returnedProducts
            }
            .store(in: &cancellables)
    }
    
    func toggleFavorite(for product: Product) {
        
        if let index = dataService.allProducts.firstIndex(where: { $0.id == product.id }) {
              dataService.allProducts[index].isFavorite.toggle()
//            allProducts = sortProductsByFavorite(products: dataService.allProducts)
          }
    }
    

    
//    private func sortProductsByFavorite(products: [Product]) -> [Product] {
//        return products.sorted { $0.isFavorite && !$1.isFavorite }
//    }
    
}
