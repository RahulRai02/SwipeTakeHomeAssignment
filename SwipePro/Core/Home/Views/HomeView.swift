//
//  HomeView.swift
//  SwipePro
//
//  Created by Rahul Rai on 22/11/24.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var vm: HomeViewModel
//    @State private var text: String = ""
    
    @State private var showProductAddScreen: Bool = false
    var body: some View {
        ZStack{
            Color.theme.background
                .ignoresSafeArea()
            
            VStack{
                homeHeader
                
                
                if !showProductAddScreen {
                    SearchBarView(searchText: $vm.searchText)
//                        .transition(.move(edge: .top))
                    
                    productGrid
                        .transition(.move(edge: .leading))
                }
                if showProductAddScreen {
                    AddProductView()
                        .transition(.move(edge: .trailing))
                }
//                productGrid

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
            Text(showProductAddScreen ? "Add Products" : "Products")
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
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12, alignment: nil),
                                GridItem(.flexible(), spacing: 12, alignment: nil)],
                      alignment: .leading,
                      spacing: 12) {
                ForEach(vm.allProducts) { product in
                    ProductCell(product: product) {
                        withAnimation(.easeInOut){
                            vm.toggleFavorite(for: product)
                        }
                        
                    }
                }
            }
            .padding()
        }
    }
}
