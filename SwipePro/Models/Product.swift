//
//  Product.swift
//  SwipePro
//
//  Created by Rahul Rai on 22/11/24.
//

import Foundation

// MARK: - Product
struct Product: Codable, Hashable {
//    var id = UUID()
    let image: String
    let price: Double?
    let productName, productType: String
    let tax: Double?
//    B8C8B49A-0649-4DEA-A58D-6002B45AB8D2
    enum CodingKeys: String, CodingKey {
        case image, price
        case productName = "product_name"
        case productType = "product_type"
        case tax
    }
    // My property
    var isFavorite: Bool = false
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(productName + productType) 
    }
}

// MARK: - ProductList
struct ProductList: Codable {
    let products: [Product]
}
