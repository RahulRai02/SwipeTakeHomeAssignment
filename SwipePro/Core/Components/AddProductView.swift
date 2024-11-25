//
//  AddProductView.swift
//  SwipePro
//
//  Created by Rahul Rai on 23/11/24.
//

import SwiftUI
import Combine

struct AddProductView: View {

    @EnvironmentObject private var vm: HomeViewModel
    let productTypes = ["Electronics", "Clothing", "Grocery", "Books", "Accessories", "Others"]
        
    var body: some View {
        NavigationView {
            Form {
                productDetailSection
                productImageSection
                submitButtonSection
                unsyncedProductsSection
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
    
    // MARK: - Product Type Picker
    private var productTypePicker: some View {
        Picker("Product Type", selection: $vm.productType) {
            ForEach(productTypes, id: \.self) {
                Text($0)
            }
        }
    }
    
    // MARK: - Validation Text Field with diff parameters
    private func validationTextField(title: String, text: Binding<String>, isValid: Bool, keyboardType: UIKeyboardType = .default) -> some View{
        TextField(title, text: text)
            .keyboardType(keyboardType)
            .foregroundColor(Color.theme.accent)
            .overlay(
                ZStack {
                    Text("☹️").opacity(isValid ? 0.0 : 1.0)
                    Text("😄").opacity(isValid ? 1.0 : 0.0)
                }
                .font(.title)
                .padding(.trailing),
                alignment: .trailing
            )
    }
    
    // MARK: - Product Detail Section
    private var productDetailSection: some View{
        Section(header: Text("Product Details").foregroundColor(Color.theme.accent)) {
            productTypePicker
            validationTextField(
                title: "Product Name",
                text: $vm.productName,
                isValid: vm.isValidProductName
            )
            validationTextField(
                title: "Selling Price",
                text: $vm.sellingPrice,
                isValid: vm.isValidSellingPrice,
                keyboardType: .decimalPad
            )
            validationTextField(
                title: "Tax Rate",
                text: $vm.taxRate,
                isValid: vm.isValidTaxRate,
                keyboardType: .decimalPad
            )
            Button("Clear fields") {
                vm.clearForm()
            }
            .foregroundColor(Color.theme.red)
            
        }
    }
    
    // MARK: - Product Image Section
    private var productImageSection: some View {
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
    }
    
    // MARK: - Submit Button Section
    private var submitButtonSection: some View {
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
    
    // MARK: - Unsynced Products Section
    private var unsyncedProductsSection: some View {
        Section(header:  Text("Products to be Synced")) {
            // Individual Sync Buttons
            ForEach(vm.savedEntities, id: \.self) { entity in
                HStack {
                    // Product Name
                    Text(entity.name ?? "No name")
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .truncationMode(.tail)

                    Spacer()

                    // Sync Button
                    Button(action: {
                        vm.syncSingleProduct(product: entity)
                        vm.dataService.getProducts()
                    }) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .foregroundColor(.blue)
                            .padding()
                    }
                }
                .padding(.vertical, 5)
            }
        }
    }

}




#Preview {
    AddProductView()
}


