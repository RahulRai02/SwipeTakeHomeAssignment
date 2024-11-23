//
//  AddProductView.swift
//  SwipePro
//
//  Created by Rahul Rai on 23/11/24.
//

import SwiftUI
import Combine

struct AddProductView: View {
    @State private var productName: String = ""
    @State private var sellingPrice: String = ""
    @State private var taxRate: String = ""
    @State private var productType: String = ""
    @State private var selectedImage: UIImage? = nil
    
    
    @State private var isImagePickerPresented: Bool = false
    @State private var isSubmitting: Bool = false
    @State private var submissionFeedback: String? = nil
    
    // Viewmodel
    @EnvironmentObject private var vm: HomeViewModel
    
    var cancellables = Set<AnyCancellable>()
    
    let productTypes = ["Electronics", "Clothing", "Grocery", "Books", "Accessories", "Others"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Product Details")) {
                    Picker("Product Type", selection: $productType) {
                        ForEach(productTypes, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    TextField("Product Name", text: $productName)
                    
                    TextField("Selling Price", text: $sellingPrice)
                        .keyboardType(.decimalPad)
                    
                    TextField("Tax Rate", text: $taxRate)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Product Image")) {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 200, maxHeight: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        Button(action: {
                            isImagePickerPresented = true
                        }) {
                            Text("Select Image")
                        }
                    }
                }
                
                Button(action: submitProduct) {
                    HStack {
                        Spacer()
                        if isSubmitting {
                            ProgressView()
                        } else {
                            Text("Submit Product")
                        }
                        Spacer()
                    }
                }
                .disabled(!isFormValid())
                
                if let feedback = submissionFeedback {
                    Text(feedback)
                        .foregroundColor(.green)
                        .font(.footnote)
                }
            }
            //            .navigationTitle("Add Product")
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(image: $selectedImage)
        }
    }
    
    // MARK: - Validation
    private func isFormValid() -> Bool {
        guard !productName.isEmpty,
              !sellingPrice.isEmpty,
              !taxRate.isEmpty,
              !productType.isEmpty,
              Double(sellingPrice) != nil,
              Double(taxRate) != nil else {
            return false
        }
        return true
    }
    
    private func submitProduct() {
        guard let price = Double(sellingPrice),
              let tax = Double(taxRate) else {
            submissionFeedback = "Please complete all fields and select a valid image."
            return
        }

        isSubmitting = true
        submissionFeedback = nil // Clear previous feedback
        
        uploadProductWithMultipartData(
            productName: productName,
            productType: productType,
            price: String(price),
            tax: String(tax),
            image: selectedImage
        ) { success in
            DispatchQueue.main.async {
                if success {
                    submissionFeedback = "Product Added Successfully!"
                } else {
                    submissionFeedback = "Failed to add product. Please try again."
                }
                isSubmitting = false
            }
        }

        vm.loadProducts()
        // Reset form after submission
        clearForm()
    }

    
    // MARK: - Clear Form
    private func clearForm() {
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


//    func uploadProductWithMultipartData(productName: String, productType: String, price: String, tax: String, image: UIImage?) {
//        // API Endpoint
//        guard let url = URL(string: "https://app.getswipe.in/api/public/add") else { return }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        
//        // Boundary
//        let boundary = "Boundary-\(UUID().uuidString)"
//        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//        
//        // Construct multipart body
//        let body = createMultipartBody(
//            parameters: [
//                "product_name": productName,
//                "product_type": productType,
//                "price": price,
//                "tax": tax
//            ],
//            image: image,
//            boundary: boundary
//        )
//        request.httpBody = body
//        
//        // Send request using URLSession
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("Error: \(error.localizedDescription)")
//                return
//            }
//            
//            guard let data = data else {
//                print("No response data received")
//                return
//            }
//            
//            // Parse response
//            do {
//                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
//                    print("Response: \(jsonResponse)")
//                }
//
//                
//            } catch {
//                print("Failed to parse response: \(error.localizedDescription)")
//            }
//        }
//        task.resume()
//
//    }

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



}


// MARK: - ImagePicker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true // Enforce 1:1 ratio
        picker.mediaTypes = ["public.image"]
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.image = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.image = originalImage
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

#Preview {
    AddProductView()
}

// Helper extension to append `String` and `Data` conveniently
extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
