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
    
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    init() {
        NSLog("App started init")
        // Monitor network connectivity
        networkMonitor.startMonitoring()
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView{
                HomeView()
                    .navigationBarBackButtonHidden()
            }
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .environmentObject(vm)
            .environmentObject(networkMonitor)
        }
    }
}
