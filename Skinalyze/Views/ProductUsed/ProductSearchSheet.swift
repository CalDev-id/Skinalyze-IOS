//
//  ProductSearchSheet.swift
//  Skinalyze
//
//  Created by Heical Chandra on 13/10/24.
//

import SwiftUI

struct ProductSearchView: View {
    @Binding var isPresented: Bool
    @State private var searchText: String = ""
    let categoryFilter: String
    let products: [SkincareProduct]
    
    var filteredProducts: [SkincareProduct] {
        if searchText.isEmpty {
            // Jika tidak ada pencarian, tampilkan semua produk dalam kategori
            return products.filter {
                ($0.category?.lowercased() ?? "") == categoryFilter.lowercased() // Menggunakan default kosong
            }
        } else {
            // Jika ada pencarian, tampilkan produk yang sesuai
            return products.filter { product in
                product.name.lowercased().contains(searchText.lowercased()) &&
                (product.category?.lowercased() ?? "") == categoryFilter.lowercased() // Menggunakan default kosong
            }
        }
    }
    @AppStorage("cleanserUsedID") private var cleanserUsedID: Int = 0
    @AppStorage("tonerUsedID") private var tonerUsedID: Int = 0
    @AppStorage("moisturizerUsedID") private var moisturizerUsedID: Int = 0
    @AppStorage("sunscreenUsedID") private var sunscreenUsedID: Int = 0
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                // Pencarian
                Text("Pick Your Product")
                    .font(.title2)
                    .bold()
                    .padding(.horizontal, 15)
                SearchBar(text: $searchText)
                
                // Daftar Produk
                List(filteredProducts) { product in
                    HStack {
                        AsyncImage(url: URL(string: product.photo)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 75, height: 70)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        } placeholder: {
                            Color.gray
                                .frame(width: 75, height: 70)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }

                        VStack(alignment: .leading) {
                            Text(product.name)
                                .font(.system(size: 18))
                                .fontWeight(.semibold)
                            HStack {
                                Text(product.brand_name)
                                    .font(.system(size: 18))
                                    .foregroundColor(.gray)
                                    
                                Spacer()
                                Text(product.category ?? "")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 5)
                                    .background(.brownSecondary)
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.vertical, 10)
                    .onTapGesture {
                        if categoryFilter == "Cleanser"{
                            cleanserUsedID = product.product_id
                        } else if categoryFilter == "Toner"{
                            tonerUsedID = product.product_id
                        } else if categoryFilter == "Moisturizer"{
                            moisturizerUsedID = product.product_id
                        } else if categoryFilter == "Sunscreen"{
                            sunscreenUsedID = product.product_id
                        }
                        isPresented.toggle()
                    }
//                    .listRowInsets(EdgeInsets()) // Menghilangkan padding bawaan
//                    .background(Color.white) // Mengganti background menjadi putih
                }
                .listStyle(PlainListStyle()) // Menggunakan list tanpa tampilan bawaan (opsional)

                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            isPresented = false
                        }
                    }
//                    ToolbarItem(placement: .navigationBarTrailing) {
//                        Button("Done") {
//                            isPresented = false
//                        }
//                    }
                }
            }
            .padding(.top, 20)
        }
    }
}

// Komponen Pencarian Kustom
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        TextField("Search your product", text: $text)
            .padding(15)
//            .padding(.horizontal, 25)
            .background(Color(.white))
            .cornerRadius(8)
            .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.brownSecondary, lineWidth: 1) // Border warna dan ketebalan
                        )
            .overlay(
                HStack {
                    Spacer()
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.brownSecondary.opacity(0.8))
                        .padding(.trailing, 10)
                        .font(.system(size: 20))
                        .fontWeight(.semibold)
                }
            )
            .padding(.horizontal)
    }
}

struct ProductSearchView_Previews: PreviewProvider {
    @State static var isPresented = true // Menggunakan @State untuk membuat binding
    
    static var previews: some View {
        NavigationView {
            ProductSearchView(isPresented: $isPresented, categoryFilter: "Cleanser", products: SkincareProductViewModel().products)
        }
    }
}
