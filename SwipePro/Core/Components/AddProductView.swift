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
                        vm.clearForm()
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
                    Button(action: vm.submitProduct) {
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
