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

    var uniqueID: UInt64 {
        let uniqueString = productName + productType + String(describing: price) + String(describing: tax) + image
        print("Unique String: \(uniqueString)")
        return strHash(uniqueString)
    }
    
    
}


// MARK: - ProductList
struct ProductList: Codable {
    let products: [Product]
}

func strHash(_ str: String) -> UInt64 {
    var result = UInt64(5381)
    let buf = [UInt8](str.utf8)
    for b in buf {
        result = 127 * (result & 0x00ffffffffffffff) + UInt64(b)
    }
    return result
}
