//
//  SwipeProApp.swift
//  SwipePro
//
//  Created by Rahul Rai on 22/11/24.
//

import SwiftUI

@main
struct SwipeProApp: App {
    @StateObject private var vm = HomeViewModel()
    let networkMonitor = NetworkMonitor.shared
    
    init() {
        networkMonitor.startMonitoring()
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView{
                HomeView()
                    .navigationBarBackButtonHidden()
            
            }
            .environmentObject(vm)
            .environmentObject(networkMonitor)
        }
    }
}
