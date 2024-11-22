//
//  CircleButtonAnimationView.swift
//  SwipePro
//
//  Created by Rahul Rai on 22/11/24.
//

import SwiftUI

struct CircleButtonAnimationView: View {
    @Binding var animate: Bool
    
    var body: some View {
        Circle()
            .stroke(lineWidth: 5.0)
            .scale(animate ? 1.0 : 0.0)
            .opacity(animate ? 0.0 : 1.0)   // Fade the circle when it scales to 1.0
            .animation(animate ? Animation.easeInOut(duration: 1.0) : .none)
    }
}

#Preview {
    CircleButtonAnimationView(animate: .constant(false))
        .foregroundColor(Color.red)
        .frame(width: 100, height: 100)
}
