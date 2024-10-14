//
//  ProductModel.swift
//  Skinalyze
//
//  Created by Heical Chandra on 12/10/24.
//
import Foundation

// Define your skincare product structure
//struct SkincareProduct: Identifiable, Codable {
//    let id = UUID()  // Untuk membuat identitas unik
//    let product_id: Int
//    let name: String
//    let link: String
//    let brand_id: Int
//    let brand_name: String
//    let category_id: Double
//    let category: String
//    let ingredients: String
//    let photo: String
//}
//

struct SkincareProduct: Identifiable, Codable {
    let id = UUID() // Anda bisa menggunakan ID unik
    let product_id: Int
    let name: String
    let link: String
    let brand_id: Int
    let brand_name: String
    let category_id: Double?
    let category: String?
    let ingredients: String?
    let photo: String
}
