//
//  HomeView.swift
//  SwipePro
//
//  Created by Rahul Rai on 22/11/24.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var vm: HomeViewModel
    
    @State private var showProductAddScreen: Bool = false
    var body: some View {
        ZStack{
            Color.theme.background
                .ignoresSafeArea()
            
            VStack{
                homeHeader
                productGrid

                Spacer()
            }
        }
    }
}

#Preview {
    HomeView()
}


extension HomeView {
    private var homeHeader: some View {
        HStack{
            CircleButtonView(iconName: showProductAddScreen ? "plus" : "info")
                .animation(.none)
                .background(
                    CircleButtonAnimationView(animate: $showProductAddScreen)
                )
            Spacer()
            Text(showProductAddScreen ? "Sell Products" : "Products")
                .font(.headline)
                .fontWeight(.heavy)
                .foregroundColor(Color.theme.accent)
                .animation(.none)
            Spacer()
            CircleButtonView(iconName: "chevron.right")
                .rotationEffect(Angle(degrees: showProductAddScreen ? 180 : 0))
                .onTapGesture {
                    withAnimation(.spring()) {
                        showProductAddScreen.toggle()
                    }
                }
        }
        .padding(.horizontal)
    }
    private var productGrid: some View {
        ScrollView{
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 2, alignment: nil),
                                GridItem(.flexible(), spacing: nil, alignment: .top)], content: {
                ForEach(vm.allProducts) { product in
                    ProductCell(product: product)
                }
                
            })
        }
    }
}
