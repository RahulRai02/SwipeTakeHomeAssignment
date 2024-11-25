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
    
    @AppStorage("isDarkMode") private var isDarkMode = false
   
    var body: some View {
        ZStack{
            Color.theme.background
                .ignoresSafeArea()
            
            VStack{
                homeHeader
                if !vm.showProductAddScreen {
                    SearchBarView(searchText: $vm.searchText)

                    if networkMonitor.isConnected{
                        productGrid
                            .transition(.move(edge: .leading))
                    }else {
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
            CircleButtonView(iconName: isDarkMode ? "moon.fill" : "sun.max")
                .opacity(vm.showProductAddScreen ? 0.0 : 1.0)
                .disabled(vm.showProductAddScreen ? true : false)
                .onTapGesture {
                    withAnimation(.easeInOut){
                        isDarkMode.toggle()
                    }
                    
                }
            
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
    
    
    // MARK: - Product Grid
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
    
    // MARK: - No Internet View
    private var noInternetView: some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.slash")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80) // Adjust size here
                .foregroundColor(Color.theme.accent)
                .transition(.move(edge: .leading))

            Text("You are Offline")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color.theme.accent)

            Text("Turn on your internet connection. You can still add products, and they will be synced once you're back online.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(Color.theme.red)
                .padding(.horizontal)

        }
        .padding()
    }

    
}
