//
//  ProductImageViewModel.swift
//  SwipePro
//
//  Created by Rahul Rai on 23/11/24.
//

import Foundation
import SwiftUI
import Combine


class ProductImageViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    @Published var isLoading: Bool = true
    
    // Initialize the ProductImageService
    private let productImageService: ProductImageService
    private let product: Product
    private var cancellables = Set<AnyCancellable>()
    
    
    init(product: Product){
        self.product = product
        self.productImageService = ProductImageService(product: product)
        self.addSubscribers()
        self.isLoading = true
    }
    
    func addSubscribers(){
        productImageService.$image
            .sink { [weak self] _ in
                self?.isLoading = false
            } receiveValue: { [weak self] (returnedImage) in
                self?.image = returnedImage
            }
            .store(in: &cancellables)
        
    }
    
}
