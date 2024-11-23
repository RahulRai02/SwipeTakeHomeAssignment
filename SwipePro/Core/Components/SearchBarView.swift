//
//  SearchBarView.swift
//  SwipePro
//
//  Created by Rahul Rai on 23/11/24.
//

import SwiftUI

struct SearchBarView: View {
    
    @Binding var searchText: String
    
    var body: some View {
        HStack{
            Image(systemName: "magnifyingglass")
                .foregroundColor(
                    searchText.isEmpty ? Color.theme.secondaryText : Color.theme.accent
                )
            
            TextField("Search by name or type", text: $searchText)
                .foregroundColor(Color.theme.accent)
                .autocorrectionDisabled(true)
                .overlay(
                    Image(systemName: "xmark.circle.fill")
                        .padding()
                        .offset(x: 10)
                        .foregroundColor(Color.theme.accent)
//                        .background(Color.red)
                        .opacity(searchText.isEmpty ? 0.0 : 1.0)
                    
                        .onTapGesture {
                            UIApplication.shared.endEditing()
                            searchText = ""
                        }
                    ,alignment: .trailing
                )
            
        }
        .font(.headline)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.theme.background)
                .shadow(color: Color.theme.accent.opacity(0.15), radius: 10, x: 0.0, y: 0.0)
        )
        .padding()
    }
}

#Preview {
    SearchBarView(searchText: .constant(""))
}

// Made this extension in order to dismiss the keyboard when we click on the clear button ....

extension UIApplication {
    func endEditing(){
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
