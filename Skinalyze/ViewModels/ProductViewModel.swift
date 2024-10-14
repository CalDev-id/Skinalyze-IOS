//
//  ProductViewModel.swift
//  Skinalyze
//
//  Created by Heical Chandra on 12/10/24.
//

//import Foundation
//import Combine
//
//class ProductViewModel: ObservableObject {
//    @Published var products: [Product] = []
//    @Published var searchText: String = ""
//    
//    private var cancellables = Set<AnyCancellable>()
//    
//    init() {
//        loadProducts()
//    }
//    
//    func loadProducts() {
//        // Lokasi file JSON di bundle
//        if let url = Bundle.main.url(forResource: "SkincareProduct_FilteredBrand", withExtension: "json") {
//            do {
//                let data = try Data(contentsOf: url)
//                let decodedProducts = try JSONDecoder().decode([Product].self, from: data)
//                self.products = decodedProducts
//            } catch {
//                print("Failed to load or decode JSON: \(error)")
//            }
//        } else {
//            print("Failed to find SkincareProduct_FilteredBrand.json")
//        }
//    }
//    
//    var filteredProducts: [Product] {
//        if searchText.isEmpty {
//            return products
//        } else {
//            return products.filter { $0.name.lowercased().contains(searchText.lowercased()) }
//        }
//    }
//}

import Foundation

class SkincareProductViewModel: ObservableObject {
    @Published var products: [SkincareProduct] = []
    
    func loadJSON() {
        if let url = Bundle.main.url(forResource: "SkincareProducts", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let loadedProducts = try decoder.decode([SkincareProduct].self, from: data)
                DispatchQueue.main.async {
                    self.products = loadedProducts
                    print("Loaded products: \(self.products)") // Pastikan ini menampilkan produk
                    print("Products Count: \(self.products.count)") // Hitung jumlah produk
                }
            } catch {
                print("Failed to load JSON: \(error)")
            }
        } else {
            print("JSON file not found")
        }
    }

}
