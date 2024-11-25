//
//  Data.swift
//  SwipePro
//
//  Created by Rahul Rai on 26/11/24.
//

import Foundation

// Helper extension to append `String` and `Data`
extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
