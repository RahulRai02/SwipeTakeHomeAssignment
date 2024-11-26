# Swipe Takehome App

A beautiful and functional iOS application with two key screens: **Product Listing** and **Add Product**.

---

## 🚀 Features  

### **Screen 1: Product Listing**  
- [x] Display a scrollable list of products retrieved from a public API.  
- [x] **Search Products**: Search through the product list in real time.  
- [x] **Product Card**:
  - Shows product details (Name, Type, Price, Tax).  
  - Includes product image (default image if URL is empty).  
- [x] **Favorite Feature**:
  - Tap the heart icon to mark a product as favorite.  
  - Favorited products appear at the top of the list, saved locally.  
- [x] **Loading Indicator**: Visual progress bar to indicate data loading.  
- [x] Navigation to **Add Product** screen via a button.  

---

### **Screen 2: Add Product**  
- [x] **Product Form**:
  - Fields for product name, type, selling price, and tax rate.  
  - Validation for all fields (e.g., non-empty, decimal inputs).  
- [x] **Product Type Selector**: Choose a product type from a list.  
- [x] **Optional Image Upload**:
  - Supports JPEG/PNG images with a 1:1 ratio.  
- [x] **Offline Mode with Core Data**:
  - Products are saved locally when offline.  
  - Synced to the server when the internet connection is restored.  
  - Sync status shown in the "Products to Be Synced" section.  
- [x] **User Feedback**:
  - Clear confirmation or error messages for actions.  
  - Displays API response after product submission.  

---

## 🛠 API Endpoints  

### **Get Products**  
- **URL**: [https://app.getswipe.in/api/public/get](https://app.getswipe.in/api/public/get)  
- **Method**: GET  
- **Response Example**:  
```json
[
  {
    "image": "https://example.com/product1.png",
    "price": 1694.91,
    "product_name": "Testing App",
    "product_type": "Product",
    "tax": 18.0
  },
  {
    "image": "https://example.com/product2.png",
    "price": 84745.76,
    "product_name": "Testing Update",
    "product_type": "Service",
    "tax": 18.0
  }
]
```

### Upload Products

- **URL**: [https://app.getswipe.in/api/public/add](https://app.getswipe.in/api/public/add)  
- **Method**: `POST`  
- **Content-Type**: `multipart/form-data`  

---

## 📦 Minimum Requirements  
- **iOS Deployment Target**: iOS 15  
- **Tools**: Xcode 15+  
- **How to Run**:
  1. Clone the Repo using `git clone https://github.com/RahulRai02/SwipeTakeHomeAssignment.git`
  1. Open `SwipePro.xcodeproj`.  
  2. Set the minimum deployment target to iOS 15.  
  3. Build and run on the simulator or a physical device.  

---

## 📂 Offline Functionality  
Products created while offline are stored using Core Data and displayed in the **"Products to Be Synced"** section in the Add Product screen.  
- [x] Each product has a "Sync" button to upload once the network is back online.  
- [x] Offline products automatically persist across app sessions.  

---

## 🖼 Screenshots & Videos  
_Add screenshots and videos of the app in action here._  

| **HomeView Dark mode** | **HomeView Light mode** |
|----------------------------|-------------------------|
| ![DarkMode_HomeView](https://github.com/user-attachments/assets/876ba03d-4714-41fa-b83a-7f3b150a0feb) | ![LightMode_HomeView](https://github.com/user-attachments/assets/e2270948-9fd0-4b97-b224-3e4bc515c487) |
| **AddProductView Dark Mode** | **AddProductView Light Mode** |
|![DarkMode_AddProductView](https://github.com/user-attachments/assets/92343508-204e-4433-a6a3-525d7dea59c6) | ![LightMode_AddProductView](https://github.com/user-attachments/assets/17759404-063a-4aa6-9eaa-1995125a2bb9) |
| **Offline State Dark Mode** | **Offline State Light Mode** |
| ![DarkMode_OfflineState](https://github.com/user-attachments/assets/a3e313ee-ff89-4bf6-a462-c888224c1246) | ![LightMode_OfflineState](https://github.com/user-attachments/assets/cca693e3-b74b-4cc5-861a-0845c262c182) |
| **Product to be synced** | **Click on upload button** |
| ![ProductToSync](https://github.com/user-attachments/assets/4b365861-e464-45ee-9c10-58c7ec507da8) | ![AddedProductWhenOnlineByClick](https://github.com/user-attachments/assets/70be21a8-d0b1-429b-a021-e52d3beb14ce) |
| **Product added to main homescreen when online** | **Liked the added product** |
| ![ProductAdded](https://github.com/user-attachments/assets/ed23c630-5f7f-455b-85a8-b9f38f312c88) | ![ProductLiked](https://github.com/user-attachments/assets/fb8b21b7-0b59-4575-8312-f09ef2574fae) |
| **Search by Title** | **Search by Type** |
| ![Search by title](https://github.com/user-attachments/assets/7369ff66-2551-45b9-95a5-4ab02b14cd76) | ![SearchByType](https://github.com/user-attachments/assets/396626e2-df0b-45b5-8a83-c5ec02b6c10d) |
---

## 🌐 Technologies Used  
- **Swift** & **SwiftUI**  
- **Core Data** & **App Storage**for offline data persistence, 
- **URLSession** for network calls.  
- **MVVM Architecture** for clean code structure.  

---
## Video Link

https://drive.google.com/file/d/1P-SJhL59CJ-v8md5YXn-5Y868RoTqQE7/view?usp=sharing



https://github.com/user-attachments/assets/e90e8d65-a147-4f3f-ae45-74f763edc6ed

---
