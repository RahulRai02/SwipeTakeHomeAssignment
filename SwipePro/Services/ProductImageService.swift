//
//  ProductImageService.swift
//  SwipePro
//
//  Created by Rahul Rai on 23/11/24.
//

import Foundation
import SwiftUI
import Combine  

class ProductImageService {
    @Published var image: UIImage? = nil
    private var imageSubscription: AnyCancellable?
    private let product: Product
    
    init(product: Product){
        self.product = product
        downloadProductImage()
    }
    
    private func getPlaceholderImage() -> UIImage {
        return UIImage(named: "placeholder")!
    }
//    
    
    func downloadProductImage(){
        guard let url = URL(string: product.image) else{
            self.image = getPlaceholderImage()
            return
        }
//        print("here")
        
        imageSubscription = URLSession.shared.dataTaskPublisher(for: url)
            .subscribe(on: DispatchQueue.global(qos: .default))
            .tryMap{ (output) -> Data in
                guard let response = output.response as? HTTPURLResponse, response.statusCode >= 200 && response.statusCode < 300 else {
                    throw URLError(.badServerResponse)
                }
                return output.data
            }
            .receive(on: DispatchQueue.main)
            .sink { (completion) in
                switch completion{
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                }
            } receiveValue: {[weak self] (returnedData) in
                self?.image = UIImage(data: returnedData)
                self?.imageSubscription?.cancel()
            }
        
    }
}

