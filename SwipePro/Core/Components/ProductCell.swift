//
//  ProductCell.swift
//  SwipePro
//
//  Created by Rahul Rai on 22/11/24.
//

import SwiftUI

struct ProductCell: View {
    let product : Product
    
    var body: some View {
        VStack(spacing: 0) {
            // Product Image

            Image("waterFall")
                .resizable()
                .scaledToFit()
                .frame(height: 150)
                .clipped()
                .cornerRadius(12)
                .padding(.horizontal, 4)

            // Product Details
            VStack(alignment: .leading, spacing: 2) {
  
                Text(product.productName ?? "No Name")
                    .font(.headline)
                    .lineLimit(2)
                    .foregroundColor(Color.theme.accent)

                // Tags for Category and Tax
                HStack(spacing: 4) {
                    CategoryItemTag(text: product.productType ?? "Mix", backgroundColor: Color.purple.opacity(0.4), textColor: Color.primary)
                    if let tax = product.tax {
                        CategoryItemTag(
                            text: "\(tax)%",
                            backgroundColor: Color.purple.opacity(0.4),
                            textColor: Color.primary
                        )
                    }
                }

                // Product Price
                HStack {
                    if let price = product.price {
                        Text("₹ \(price, specifier: "%.2f")")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(Color.theme.accent)
                    }
                    Spacer()
                }
            }
//            .frame(maxWidth: .infinity)
//            .background(Color.green)
            .padding([.horizontal, .bottom], 12)
//            .padding()
   
        }
//        .frame(width: 150, height: 230)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.theme.background)
//        .background(Color.red)
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.3), radius: 10, x: 0, y: 2)
    }
}

#Preview {
    ProductCell(product: Product(image: "waterFall", price: 150, productName: "Water", productType: "Grocery", tax: 12))
}


struct CategoryItemTag: View {
    let text: String
    let backgroundColor: Color
    let textColor: Color

    var body: some View {
        Text(text)
            .font(.system(size: 8, weight: .medium))
            .foregroundColor(textColor)
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .background(backgroundColor)
            .cornerRadius(8)
    }
}