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

---






## 🌐 Technologies Used  
- **Swift** & **SwiftUI**  
- **Core Data** & **App Storage**for offline data persistence, 
- **URLSession** for network calls.  
- **MVVM Architecture** for clean code structure.  

---

