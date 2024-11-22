//
//  HomeViewModel.swift
//  SwipePro
//
//  Created by Rahul Rai on 22/11/24.
//

import Foundation
import Combine

class HomeViewModel : ObservableObject {
//    @Published var allProducts:
    @Published var allProducts: [Product] = []
    
    private let dataService = ProductDataService()
    private var cancellables = Set<AnyCancellable>()
    
    
    init(){
        addSubscribers()
    }
    
    func addSubscribers(){
        dataService.$allProducts
            .sink { [weak self] (returnedProducts) in
                self?.allProducts = returnedProducts
            }
            .store(in: &cancellables)
    }
    
}
