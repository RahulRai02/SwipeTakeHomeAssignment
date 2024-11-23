//
//  ProductImageView.swift
//  SwipePro
//
//  Created by Rahul Rai on 23/11/24.
//

import SwiftUI

struct ProductImageView: View {
    @StateObject var vm : ProductImageViewModel
    
    init(product: Product){
        _vm = StateObject(wrappedValue: ProductImageViewModel(product: product))
    }
    
    var body: some View {
//        ZStack{
        if let image = vm.image {
            Image(uiImage: image)
                .resizable()
                .frame(width: 150, height: 150)
                .aspectRatio(contentMode: .fit)
                .clipped()
                .cornerRadius(12)
                .padding(.vertical, 8)
//                .resizable()
//                .scaledToFit()
//                .frame(width: 150, height: 150)
//                .clipped()
//                .cornerRadius(12)
//                .padding(.horizontal, 4)
            
        }else if vm.isLoading {
            ProgressView()
        }
//    }
        
//        Image("waterFall")
//            .resizable()
//            .scaledToFit()
//            .frame(height: 150)
//            .clipped()
//            .cornerRadius(12)
//            .padding(.horizontal, 4)
    }
}

#Preview {
    ProductImageView(product: Product(image: "waterFall", price: 150, productName: "Water", productType: "Grocery", tax: 12))
}
