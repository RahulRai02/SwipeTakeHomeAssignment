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
    

    
    init(){
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
                return output.data
            }
            .receive(on: DispatchQueue.main)
            .decode(type: [Product].self, decoder: JSONDecoder())
            .sink { (completion) in
                switch completion{
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                }
            } receiveValue: {[weak self] (returnedProducts) in
                self?.allProducts = returnedProducts
                self?.productSubscription?.cancel()
            }
        
        
    }
    
    
}

