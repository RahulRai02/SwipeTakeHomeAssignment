//
//  LocalProductViewModel.swift
//  SwipePro
//
//  Created by Rahul Rai on 25/11/24.
//


import Foundation
import SwiftUI
import CoreData

class LocalProductViewModel : ObservableObject{
    let container: NSPersistentContainer
    @Published var savedEntities: [ProductEntity] = []
    
    init() {
        
        container = NSPersistentContainer(name: "ProductContainer")
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Error loading Core data \(error)")
            }else{
                print("Successfully loaded core data")
            }
        }
        fetchProducts()
//        self.deleteAll()
        
        
    }
    func deleteAll(){
        for entity in savedEntities{
            container.viewContext.delete(entity)
        }
        saveData()
    }
    
        func fetchProducts() {
            let request = NSFetchRequest<ProductEntity>(entityName: "ProductEntity")
            do {
                savedEntities = try container.viewContext.fetch(request)
            } catch let error {
                print("Error in fetching \(error)")
            }
        }
        
    func addProduct(productName: String, productType: String, price: Double, tax: Double, isSynced: Bool, image: UIImage) {
        let newProduct = ProductEntity(context: container.viewContext)
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Could not convert image to data")
            return
        }
        newProduct.image = imageData
        newProduct.name = productName
        newProduct.price = price
        newProduct.type = productType
        newProduct.tax = tax
        newProduct.isSynced = false
        saveData()
        print("Sync successfull and produce added ")
    }
        
        func deleteProduct(indexSet: IndexSet) {
            guard let index = indexSet.first else { return }
            let entity = savedEntities[index]
            container.viewContext.delete(entity)
            
            saveData()
        }
        
        
        func saveData(){
            do{
                try container.viewContext.save()
                fetchProducts()
            } catch let error {
                print("Error in saving \(error)")
            }
        }
    
}
