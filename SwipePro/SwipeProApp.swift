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
    var body: some Scene {
        WindowGroup {
            NavigationView{
                HomeView()
                    .navigationBarBackButtonHidden()
            }
            .environmentObject(vm)
        }
    }
}
