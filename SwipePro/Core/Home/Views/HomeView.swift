//
//  HomeView.swift
//  SwipePro
//
//  Created by Rahul Rai on 22/11/24.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var vm: HomeViewModel 
    @EnvironmentObject private var networkMonitor: NetworkMonitor
   
    var body: some View {
        ZStack{
            Color.theme.background
                .ignoresSafeArea()
            
            VStack{
                homeHeader
                
                
                if !vm.showProductAddScreen {
                    SearchBarView(searchText: $vm.searchText)
                    if networkMonitor.isConnected {

                        productGrid
                            .transition(.move(edge: .leading))
                    } else {
                        noInternetView
                            .transition(.move(edge: .leading))
                    }
     

                }
                if vm.showProductAddScreen {
                    AddProductView()
                        .transition(.move(edge: .trailing))
                }

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
            CircleButtonView(iconName: vm.showProductAddScreen ? "plus" : "info")
                    .opacity(vm.showProductAddScreen ? 0.0 : 1.0)
                    .disabled(vm.showProductAddScreen ? true : false)
        
                    .animation(.none)

            Spacer()
            Text(vm.showProductAddScreen ? "Add Products" : "Products")
                .font(.headline)
                .fontWeight(.heavy)
                .foregroundColor(Color.theme.accent)
                .animation(.none)
            Spacer()
            CircleButtonView(iconName: "chevron.right")
                .rotationEffect(Angle(degrees: vm.showProductAddScreen ? 180 : 0))
                .onTapGesture {
                    withAnimation(.spring()) {                        
                        vm.showProductAddScreen.toggle()
                        
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
    private var noInternetView: some View {
        VStack{
            
            Image(systemName: "wifi.slash")
                .resizable()
                .scaledToFit()
                .transition(.move(edge: .leading))
            Text("You are Offline, Turn on your internet connection. You could still add products, they will be synced once you are online.")
                .font(.caption)
                .fontWeight(.heavy)
                .foregroundColor(Color.theme.accent)
                .padding()
                .transition(.move(edge: .leading))
        }
        .padding()
    }
}
