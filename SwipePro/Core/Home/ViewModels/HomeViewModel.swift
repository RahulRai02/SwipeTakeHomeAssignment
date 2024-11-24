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
    @Published var showProductAddScreen: Bool = false
    
    let dataService = ProductDataService()
    private var cancellables = Set<AnyCancellable>()
    
    
    @Published var productName: String = ""
    @Published var isValidProductName: Bool = false
    
    @Published var sellingPrice: String = ""
    @Published var isValidSellingPrice: Bool = false
    
    @Published var taxRate: String = ""
    @Published var isValidTaxRate: Bool = false
    
    @Published var productType: String = "Others"
//    @Published var isValidProductType: Bool = false
    
    @Published var selectedImage: UIImage? = nil
    
    
//    @Published var isValid: Bool = false
    @Published var showButton: Bool = false
    @Published var alertItem: AlertItem?
    
    
    @Published var isImagePickerPresented: Bool = false
    @Published var isSubmitting: Bool = false

    @Published var submissionFeedback: String? = nil
    
    
    enum SortOption {
        case favorite
    }
    

    
    init(){
        addSubscribers()
        productNameSubscriber()
        sellingPriceSubscriber()
        taxRateSubscriber()
//        productTypeSubscriber()
        
    }
    
    func productNameSubscriber(){
        $productName
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .map({ (productName) -> Bool in
                if productName.count > 0 && productName.count < 20 {
                    return true
                }
                return false
            })
            .sink(receiveValue: { [weak self] (isValidProductName) in
                self?.isValidProductName = isValidProductName
            })
            .store(in: &cancellables)
    }
    
    func sellingPriceSubscriber(){
        $sellingPrice
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .map({ (sellingPrice) -> Bool in
                if let _ = Double(sellingPrice), !sellingPrice.isEmpty {
                    return true
                }
                return false
            })
            .sink(receiveValue: { [weak self] (isValidSellingPrice) in
                self?.isValidSellingPrice = isValidSellingPrice
            })
            .store(in: &cancellables)
    }
    
    func taxRateSubscriber(){
        $taxRate
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .map({ (taxRate) -> Bool in
                if let _ = Double(taxRate), !taxRate.isEmpty {
                    return true
                }
                return false
            })
            .sink(receiveValue: { [weak self] (isValidTaxRate) in
                self?.isValidTaxRate = isValidTaxRate
            })
            .store(in: &cancellables)
    }
                     
    
//    func refreshAllProducts() {
////        print("Fetching fresh data")
//        dataService.getProducts()
////        print("Fetched fresh data")
//    }

    
    
    // MARK: - FILTER AND SORT
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
        $searchText
            .combineLatest(dataService.$allProducts, $sortOption)
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)

            .map(filterAndSortCoinsByFavorite)
            .sink { [weak self] (returnedProducts) in
                self?.allProducts = returnedProducts
            }
            .store(in: &cancellables)
        }
    
    func toggleFavorite(for product: Product) {
        dataService.toggleFavorite(product: product)
//        if let index = dataService.allProducts.firstIndex(where: { $0.id == product.id }) {
//              dataService.allProducts[index].isFavorite.toggle()
//          }
    }
    
    


    
}
