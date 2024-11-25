//
//  HomeViewModel.swift
//  SwipePro
//
//  Created by Rahul Rai on 22/11/24.
//

import Foundation
import Combine
import SwiftUI
import CoreData


class HomeViewModel : ObservableObject {

//    @Published var localProductVM: LocalProductViewModel = LocalProductViewModel()
    @Published var allProducts: [Product] = []

    
    @Published var searchText: String = ""
    @Published var sortOption: SortOption = .favorite
    @Published var showProductAddScreen: Bool = false
    
    let dataService = ProductDataService()
    private var cancellables = Set<AnyCancellable>()
    
    
    @Published var productName: String = ""
    @Published var isValidProductName: Bool = false
    
    @Published var sellingPrice: String = ""
    @Published var isValidSellingPrice: Bool = false
    
    @Published var taxRate: String = ""
    @Published var isValidTaxRate: Bool = false
    
    @Published var productType: String = "Others"
//    @Published var isValidProductType: Bool = false
    
    @Published var selectedImage: UIImage? = nil
    
    
//    @Published var isValid: Bool = false
    @Published var showButton: Bool = false
    @Published var alertItem: AlertItem?
    
    
    @Published var isImagePickerPresented: Bool = false
    @Published var isSubmitting: Bool = false

    @Published var submissionFeedback: String? = nil
    
    
    // Core data
    let container: NSPersistentContainer
    @Published var savedEntities: [ProductEntity] = []
    
    
    enum SortOption {
        case favorite
    }
    

    
    init(){
        container = NSPersistentContainer(name: "ProductContainer")
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Error loading Core data \(error)")
            }else{
                print("Successfully loaded core data")
            }
        }
        fetchProducts()
        
        
        NSLog("HomeViewModel init")
        addSubscribers()
        productNameSubscriber()
        sellingPriceSubscriber()
        taxRateSubscriber()

        
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
    
    
    func productNameSubscriber(){
        $productName
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .map({ (productName) -> Bool in
                if productName.count > 0 && productName.count < 20 {
                    return true
                }
                return false
            })
            .sink(receiveValue: { [weak self] (isValidProductName) in
                self?.isValidProductName = isValidProductName
            })
            .store(in: &cancellables)
    }
    
    func sellingPriceSubscriber(){
        $sellingPrice
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .map({ (sellingPrice) -> Bool in
                if let _ = Double(sellingPrice), !sellingPrice.isEmpty {
                    return true
                }
                return false
            })
            .sink(receiveValue: { [weak self] (isValidSellingPrice) in
                self?.isValidSellingPrice = isValidSellingPrice
            })
            .store(in: &cancellables)
    }
    
    func taxRateSubscriber(){
        $taxRate
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .map({ (taxRate) -> Bool in
                if let _ = Double(taxRate), !taxRate.isEmpty {
                    return true
                }
                return false
            })
            .sink(receiveValue: { [weak self] (isValidTaxRate) in
                self?.isValidTaxRate = isValidTaxRate
            })
            .store(in: &cancellables)
    }
                     
    
//    func refreshAllProducts() {
////        print("Fetching fresh data")
//        dataService.getProducts()
////        print("Fetched fresh data")
//    }

    
    
    // MARK: - FILTER AND SORT
    private func sortProductsByOption(sort: SortOption, products: [Product]) -> [Product] {
        switch sort{
        case .favorite:
            return products.sorted { $0.isFavorite && !$1.isFavorite }
        }
    }
    
    private func filterAndSortCoinsByFavorite(text: String, product: [Product], sort: SortOption ) -> [Product] {
        var filteredCoins = filterCoins(text: text, product: product)

        filteredCoins = sortProductsByOption(sort: sort, products: filteredCoins)
        return filteredCoins
    }
        
    
    private func filterCoins(text: String, product: [Product]) -> [Product] {
        guard !text.isEmpty else {
            return product
        }
        let lowercasedText = text.lowercased()
        return product.filter { (product) -> Bool in
            return (product.productName.lowercased().contains(lowercasedText)) || product.productType.lowercased().contains(lowercasedText)
        }
    }
    
    func addSubscribers(){
        $searchText
            .combineLatest(dataService.$allProducts, $sortOption)
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)

            .map(filterAndSortCoinsByFavorite)
            .sink { [weak self] (returnedProducts) in
                self?.allProducts = returnedProducts
            }
            .store(in: &cancellables)
        }
    
    func toggleFavorite(for product: Product) {
        dataService.toggleFavorite(product: product)

    }
    
    
    func submitProduct() {
        guard let price = Double(sellingPrice),
              let tax = Double(taxRate) else {
            submissionFeedback = "Please complete all fields"
            return
        }

        isSubmitting = true
        submissionFeedback = nil
//        print("☹️\(NetworkMonitor.shared.isConnected)")
        
        if !NetworkMonitor.shared.isConnected {
            alertItem = AlertContext.noInternet

            // Add to Core data

            
            addProduct(productName: productName, productType: productType, price: price, tax: tax, isSynced: false, image: selectedImage ?? UIImage(named: "placeholder")!)
            isSubmitting = false
            clearForm()
            return
        }
        
        
        
        uploadProductWithMultipartData(
            productName: productName,
            productType: productType,
            price: String(price),
            tax: String(tax),
            image: selectedImage
        ) { success in
            DispatchQueue.main.async {
                self.isSubmitting = false
                if success {
                    self.alertItem = AlertContext.addProductSuccess
//                    dataService.getProducts()
                    self.dataService.getProducts()
                    self.clearForm()
                } else {
                    self.alertItem = AlertContext.addProductError
                }
            }
        }
        // Reset form after submission
        clearForm()
    }

    
    // MARK: - Clear Form
    func clearForm() {
        productName = ""
        sellingPrice = ""
        taxRate = ""
        productType = ""
        selectedImage = nil
    }
  
    func uploadProductWithMultipartData(productName: String, productType: String, price: String, tax: String, image: UIImage?, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "https://app.getswipe.in/api/public/add") else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Boundary
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Construct multipart body
        let body = createMultipartBody(
            parameters: [
                "product_name": productName,
                "product_type": productType,
                "price": price,
                "tax": tax
            ],
            image: image,
            boundary: boundary
        )
        request.httpBody = body
        
        // Send request using URLSession
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let data = data else {
                print("No response data received")
                completion(false)
                return
            }
            
            // Parse response
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("Response: \(jsonResponse)")
                    completion(true)
                } else {
                    completion(false)
                }
            } catch {
                print("Failed to parse response: \(error.localizedDescription)")
                completion(false)
            }
        }
        task.resume()
    }

    func createMultipartBody(parameters: [String: String], image: UIImage?, boundary: String) -> Data {
        var body = Data()
        
        // Add text fields
        for (key, value) in parameters {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.append("\(value)\r\n")
        }
        
        // Add image if available
        if let image = image,
           let imageData = image.jpegData(compressionQuality: 0.8) {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"files[]\"; filename=\"image.jpg\"\r\n")
            body.append("Content-Type: image/jpeg\r\n\r\n")
            body.append(imageData)
            body.append("\r\n")
        }
        
        // End the multipart body
        body.append("--\(boundary)--\r\n")
        return body
    }

    
    public func syncProductsWithServer() {
        print("Syncing products with server...")
        
        let unsyncedProducts = savedEntities.filter { !$0.isSynced }
        
        guard !unsyncedProducts.isEmpty else {
             print("All products are already synced.")
             return
         }
        for product in unsyncedProducts {
            guard let productName = product.name,
                  let productType = product.type,
                  let imageData = product.image,
                  let image = UIImage(data: imageData) else {
                print("Invalid product data. Skipping...")
                continue
            }
            
            uploadProductWithMultipartData(
                productName: productName,
                productType: productType,
                price: String(product.price),
                tax: String(product.tax),
                image: image
            ) { success in
                if success {
                    DispatchQueue.main.async {
                        // Update product sync status in Core Data
                        product.isSynced = true
                        self.saveData()
                        print("Product \(productName) synced successfully.")
                        
                    }
                } else {
                    print("Failed to sync product: \(productName)")
                }
            }
//            localProductVM.deleteProduct(indexSet: IndexSet(integer: localProductVM.savedEntities.firstIndex(of: product)!))
        }
        deleteAll()
    }
    
    func syncSingleProduct(product: ProductEntity) {
        guard let productName = product.name,
              let productType = product.type,
              let imageData = product.image,
              let image = UIImage(data: imageData) else {
            print("Invalid product data. Skipping...")
            return
        }

        uploadProductWithMultipartData(
            productName: productName,
            productType: productType,
            price: String(product.price),
            tax: String(product.tax),
            image: image
        ) { success in
            if success {
                DispatchQueue.main.async {
                    // Update product sync status in Core Data
                    product.isSynced = true
                    self.saveData()
                    

                    self.deleteProduct(indexSet: IndexSet(integer: self.savedEntities.firstIndex(of: product)!))
                    
                    self.alertItem = AlertContext.addProductSuccess
                    
                    print("Product \(productName) synced and removed successfully.")
                }
            } else {
                print("Failed to sync product: \(productName)")
            }
        }
    }


 
    
}
