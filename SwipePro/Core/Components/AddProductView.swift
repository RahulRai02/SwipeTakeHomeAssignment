//
//  AddProductView.swift
//  SwipePro
//
//  Created by Rahul Rai on 23/11/24.
//

import SwiftUI
import Combine

struct AddProductView: View {
        
    // Viewmodel
    @EnvironmentObject private var vm: HomeViewModel
    
    var cancellables = Set<AnyCancellable>()
    
    let productTypes = ["Electronics", "Clothing", "Grocery", "Books", "Accessories", "Others"]
    

    
    var body: some View {
        NavigationView {
            Form {
                // MARK: - Product Details
                Section(header: Text("Product Details").foregroundColor(Color.theme.accent)) {
                    Picker("Product Type", selection: $vm.productType) {
                        ForEach(productTypes, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    TextField("Product Name", text: $vm.productName)
                        .foregroundColor(Color.theme.accent)
                        .overlay(
                            ZStack{
                                Text("☹️")
                                    .opacity(vm.isValidProductName ? 0.0 : 1.0)
                                Text("😄")
                                    .opacity(vm.isValidProductName ? 1.0 : 0.0)
                            }
                            .font(.title)
                            .padding(.trailing),
                            alignment: .trailing
                        )
                    
                    TextField("Selling Price", text: $vm.sellingPrice)
                        .keyboardType(.decimalPad)
                        .foregroundColor(Color.theme.accent)
                        .overlay(
                            ZStack{
                            Text("😕")
                                .opacity(vm.isValidSellingPrice ? 0.0 : 1.0)

                            Text("😄")
                                .opacity(vm.isValidSellingPrice ? 1.0 : 0.0)
                            }
                                .font(.title)
                                .padding(.trailing),
                            alignment: .trailing
                        )
                    TextField("Tax Rate", text: $vm.taxRate)
                        .keyboardType(.decimalPad)
                        .foregroundColor(Color.theme.accent)
                        .overlay(
                            ZStack{
                                Text("😕")
                                    .opacity(vm.isValidTaxRate ? 0.0 : 1.0)
                                Text("😄")
                                    .opacity(vm.isValidTaxRate ? 1.0 : 0.0)
                            }
                                .font(.title)
                                .padding(.trailing),
                            alignment: .trailing
                        )
                    Button("Clear fields") {
                        clearForm()
                    }
                    .foregroundColor(Color.theme.red)
                }
                // MARK: - Product Image Selection
                Section(header: Text("Product Image")) {
                    if let image = vm.selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 200, maxHeight: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        Button(action: {
                            vm.isImagePickerPresented = true
                        }) {
                            Text("Select Image")
                        }
                    }
                }
                
                Section{
                    // MARK: - Submit Button ACTION
                    Button(action: submitProduct) {
                        HStack {
                            Spacer()
                            if vm.isSubmitting {
                                ProgressView()
                            } else {
                                Text("Submit Product")
                            }
                            Spacer()
                        }
                    }
                    .foregroundColor(Color.theme.green)
                    .disabled(vm.isValidProductName && vm.isValidSellingPrice && vm.isValidTaxRate ? false : true)
                }
                

            }
            
        }
        .sheet(isPresented: $vm.isImagePickerPresented) {
            ImagePicker(image: $vm.selectedImage)
        }
        
        .alert(item: $vm.alertItem){ alertItem in
            Alert(title: alertItem.title,
                  message: alertItem.message,
                  dismissButton: alertItem.dismissButton)
        }

        
    }
    
    
    private func submitProduct() {
        guard let price = Double(vm.sellingPrice),
              let tax = Double(vm.taxRate) else {
            vm.submissionFeedback = "Please complete all fields"
            return
        }

        vm.isSubmitting = true
        vm.submissionFeedback = nil // Clear previous feedback
        
        uploadProductWithMultipartData(
            productName: vm.productName,
            productType: vm.productType,
            price: String(price),
            tax: String(tax),
            image: vm.selectedImage
        ) { success in
            DispatchQueue.main.async {
                vm.isSubmitting = false
                if success {
                    vm.alertItem = AlertContext.addProductSuccess
                    clearForm()
                } else {
                    vm.alertItem = AlertContext.addProductError
                }
            }
        }
        // Reset form after submission
        clearForm()
    }

    
    // MARK: - Clear Form
    private func clearForm() {
        vm.productName = ""
        vm.sellingPrice = ""
        vm.taxRate = ""
        vm.productType = ""
        vm.selectedImage = nil
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
