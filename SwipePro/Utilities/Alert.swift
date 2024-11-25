//
//  Alert.swift
//  SwipePro
//
//  Created by Rahul Rai on 23/11/24.
//

import Foundation
import SwiftUI

struct AlertItem: Identifiable{
    let id = UUID()
    let title: Text
    let message: Text
    let dismissButton: Alert.Button
}


struct AlertContext {

    // MARK: -- Product add success and error alerts
    static let addProductSuccess        = AlertItem(title: Text("Product Added"),
                                            message: Text("Your product is Added succesfully 🥳"),
                                            dismissButton: .default(Text("OK")))
    
    static let addProductError          = AlertItem(title: Text("Product Error"),
                                            message: Text("There was an error adding your product. Please try again later."),
                                            dismissButton: .default(Text("OK")))
    
    
    
    // MARK: - Invalid Fields Alerts
    static let invalidProductName = AlertItem(title: Text("Enter less than 20 characters"),
                                                message: Text("Product name should be less than 20 characters"),
                                                dismissButton: .default(Text("OK")))
    
                     
    static let invalidPriceGiven = AlertItem(title: Text("Price should be numeric"),
                                                message: Text("Please enter a valid price"),
                                                dismissButton: .default(Text("OK")))
    
    static let invalidTaxRate = AlertItem(title: Text("Tax rate should be numeric"),
                                                message: Text("Please enter a valid tax rate"),
                                                dismissButton: .default(Text("OK")))
    
    static let invalidProductType = AlertItem(title: Text("Product type should be less than 20 characters"),
                                                message: Text("Please enter a valid product type"),
                                                dismissButton: .default(Text("OK")))
        
    static let invalidSellingPrice = AlertItem(title: Text("Invalid Selling Price"),
                                        message: Text("The selling price you entered is invalid. Please enter a valid selling price."),
                                        dismissButton: .default(Text("OK")))
    
    // Mark: - Network Alerts
    static let noInternet = AlertItem(title: Text("No Internet Connection"),
                                                message: Text("Please check your internet connection. Your item will be added once network is available"),
                                                dismissButton: .default(Text("OK")))
    
    
    static let fetchError = AlertItem(title: Text("Error Fetching Products from COREDATA"),
                                                message: Text("There was an error fetching products. Please try again by reopening the app."),
                                                dismissButton: .default(Text("OK")))
    
    static let serverNotResponding = AlertItem(title: Text("Server not responding"),
                                                message: Text("The server is not responding. Please try again later."),
                                                dismissButton: .default(Text("OK")))
}

