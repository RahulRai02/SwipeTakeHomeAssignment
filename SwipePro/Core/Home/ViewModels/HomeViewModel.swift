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
    
    @Published var allProducts: [Product] = []

    
    @Published var searchText: String = ""
    @Published var sortOption: SortOption = .favorite
    @Published var showProductAddScreen: Bool = false
    
    let dataService = ProductDataService()
    private var cancellables = Set<AnyCancellable>()
    
    
    // For form validations
    @Published var productName: String = ""
    @Published var sellingPrice: String = ""
    @Published var taxRate: String = ""
    @Published var productType: String = "Others"
    @Published var selectedImage: UIImage? = nil
    
    @Published var isValidProductName: Bool = false
    @Published var isValidSellingPrice: Bool = false
    @Published var isValidTaxRate: Bool = false
    
    
    // showButton boolean to track if the fields are valid, then show the submit button
    @Published var showButton: Bool = false
    
    // Alert
    @Published var alertItem: AlertItem?
    
    // Form submission and feedback
    @Published var isSubmitting: Bool = false
    @Published var submissionFeedback: String? = nil
    
    // Image picker
    @Published var isImagePickerPresented: Bool = false
    
    // Core data container to store offline products
    let container: NSPersistentContainer
    @Published var savedEntities: [ProductEntity] = []
    
    // MARK: - SORT OPTIONS: Could be expanded to include more sort options
    enum SortOption {
        case favorite
    }
    
    init(){
        NSLog("HomeViewModel init")
        // Initialize Core data container
        container = NSPersistentContainer(name: "ProductContainer")
        container.loadPersistentStores { description, error in
            if let error = error {
                NSLog("Error loading Core data \(error)")
            }else{
                NSLog("Successfully loaded core data")
            }
        }
        fetchProducts()
        
        // Add Subscibers inorder to listen to the changes in the allProduct array from the data service
        addSubscribers()


    }
    // MARK: - CRUD OPERATIONS FOR CORE DATA : Local Product storage in case of no internet
    // Fetch all products from Core Data
    func fetchProducts() {
        let request = NSFetchRequest<ProductEntity>(entityName: "ProductEntity")
        do {
            savedEntities = try container.viewContext.fetch(request)
        } catch let error {
            NSLog("Error in fetching \(error)")
            alertItem = AlertContext.fetchError
        }
    }
    
    // Delete all products from Core Data
    func deleteAll(){
        for entity in savedEntities{
            container.viewContext.delete(entity)
        }
        saveData()
    }
    
    // Add a new product to Core Data
    func addProduct(productName: String, productType: String, price: Double, tax: Double, isSynced: Bool, image: UIImage) {
        let newProduct = ProductEntity(context: container.viewContext)
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            NSLog("Could not convert image to data")
            return
        }
        newProduct.image = imageData
        newProduct.name = productName
        newProduct.price = price
        newProduct.type = productType
        newProduct.tax = tax
        newProduct.isSynced = false
        saveData()
        NSLog("Product added to Core Data Successfully")
    }
        
    // Delete a product from Core Data
    func deleteProduct(indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        let entity = savedEntities[index]
        container.viewContext.delete(entity)
        
        saveData()
    }
        
    // Save data to Core Data
    func saveData(){
        do{
            try container.viewContext.save()
            fetchProducts()
        } catch let error {
            NSLog("Error in saving \(error)")
        }
    }
    
    // MARK: - ADD SUBSCRIBERS For Searching, Sort, Getting Products, Form validations
    func addSubscribers(){
        // Subscribe to the changes in the searchText, allProducts and sortOption
        $searchText
            .combineLatest(dataService.$allProducts, $sortOption)
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)    // So that the search is not triggered on every change in character

            .map(filterAndSortCoinsByFavorite)
            .sink { [weak self] (returnedProducts) in
                self?.allProducts = returnedProducts
            }
            .store(in: &cancellables)
        
        // Product Name validation
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
        
        // Selling Price validation
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
        
        // Tax Rate validation
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
    

                         
    // MARK: - Filter and Sort Logic for mapping
    // Filter and Sort the products based on the search text and sort option
    private func filterAndSortCoinsByFavorite(text: String, product: [Product], sort: SortOption ) -> [Product] {
        var filteredCoins = filterCoins(text: text, product: product)

        filteredCoins = sortProductsByOption(sort: sort, products: filteredCoins)
        return filteredCoins
    }
    // Sort the products based on the sort option
    private func sortProductsByOption(sort: SortOption, products: [Product]) -> [Product] {
        switch sort{
        case .favorite:
            return products.sorted { $0.isFavorite && !$1.isFavorite }
        }
    }
    // Filter the products based on the search text
    private func filterCoins(text: String, product: [Product]) -> [Product] {
        guard !text.isEmpty else {
            return product
        }
        let lowercasedText = text.lowercased()
        return product.filter { (product) -> Bool in
            return (product.productName.lowercased().contains(lowercasedText)) || product.productType.lowercased().contains(lowercasedText)
        }
    }
    
    // MARK: - Toggle Favorite
    func toggleFavorite(for product: Product) {
        dataService.toggleFavorite(product: product)
    }
    
    // MARK: - Submit Product Logic
    func submitProduct() {
        // Unwrap the price and tax..
        guard let price = Double(sellingPrice),
              let tax = Double(taxRate) else {
            submissionFeedback = "Please complete all fields"
            return
        }

        isSubmitting = true
        submissionFeedback = nil

        // If no internet, Save the product to Core Data
        if !NetworkMonitor.shared.isConnected {
            alertItem = AlertContext.noInternet
            addProduct(productName: productName, productType: productType, price: price, tax: tax, isSynced: false, image: selectedImage ?? UIImage(named: "placeholder")!)
            isSubmitting = false
            clearForm()
            return
        }
        
        // Case, when there is internet, upload the product to the server using POST request
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
                    self.dataService.getProducts()
                    self.clearForm()
                } else {
                    self.alertItem = AlertContext.addProductError
                }
            }
        }
        // Clear the form after submission
        clearForm()
    }

    
    // MARK: - Clear Form
    func clearForm() {
        productName = ""
        sellingPrice = ""
        taxRate = ""
        selectedImage = nil
    }
    
    // MARK: - Network Calls: Upload data as Multipart form data since we are uploading file..
    
    func uploadProductWithMultipartData(productName: String, productType: String, price: String, tax: String, image: UIImage?, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "https://app.getswipe.in/api/public/add") else {
            completion(false)
            return
        }
        // Create a Post request and its requird header
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
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
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle error
            if let error = error {
                NSLog("Error: \(error.localizedDescription)")
                self.alertItem = AlertContext.serverNotResponding
                completion(false)
                return
            }
            // Handle response data
            guard let data = data else {
                NSLog("No response data received")
                self.alertItem = AlertContext.serverNotResponding
                completion(false)
                return
            }
            
            // Parse response
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    NSLog("Response: \(jsonResponse)")
                    completion(true)
                } else {
                    completion(false)
                }
            } catch {
                NSLog("Failed to parse response: \(error.localizedDescription)")
                completion(false)
            }
        }
        task.resume()
    }

    // Create a multipart body with parameters
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

    
    func syncProductsWithServer() {
        NSLog("Syncing products with server...")
        
        let unsyncedProducts = savedEntities.filter { !$0.isSynced }
        
        guard !unsyncedProducts.isEmpty else {
             NSLog("All products are already synced.")
             return
         }
        
        for product in unsyncedProducts {
            syncSingleProduct(product: product)
        }
        
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
                    self.dataService.getProducts()
                    NSLog("Product \(productName) synced and removed successfully from Core Data.")
                   
                }
            } else {
                self.alertItem = AlertContext.addProductError
                NSLog("Failed to sync product: \(productName)")
            }
        }
    }
}
