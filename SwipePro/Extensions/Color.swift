//
//  Color.swift
//  SwipePro
//
//  Created by Rahul Rai on 22/11/24.
//

import Foundation
import SwiftUI

// Want to change the color theme for the app? Make a new color theme struct below by adding respective colors on Assets



extension Color {
    static let theme = ColorTheme()
}


/// App's color theme
/// ```
/// Simplyfying names for easy access of colors
/// ```
struct ColorTheme {
    let accent = Color("AccentColor")
    let background = Color("BackgroundColor")
    let green = Color("GreenColor")
    let red = Color("RedColor")
    let secondaryText = Color("SecondaryTextColor")
}
