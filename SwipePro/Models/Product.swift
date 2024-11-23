//
//  Product.swift
//  SwipePro
//
//  Created by Rahul Rai on 22/11/24.
//

import Foundation

// MARK: - Product
struct Product: Codable, Identifiable {
    var id = UUID()
    let image: String
    let price: Double?
    let productName, productType: String
    let tax: Int?

    enum CodingKeys: String, CodingKey {
        case image, price
        case productName = "product_name"
        case productType = "product_type"
        case tax
    }
    // My property
    var isFavorite: Bool = false
}

// MARK: - ProductList
struct ProductList: Codable {
    let products: [Product]
}
