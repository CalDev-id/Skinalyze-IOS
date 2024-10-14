//
//  EditProfileView.swift
//  Skinalyze
//
//  Created by Heical Chandra on 14/10/24.
//

import SwiftUI

struct EditProfileView: View {
    @AppStorage("userName") private var userName: String = ""
    @AppStorage("userAge") private var userAge: Int = 0 // Change to Int
    @AppStorage("userGender") private var userGender: String = ""
    @Environment(\.presentationMode) var presentationMode
    
    let genders = ["Male", "Female", "Other"]
    
    var body: some View {
        VStack{
            Divider()
                .padding(.bottom)
            VStack {
                Group{
                    Image("Maskot")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .padding()
                }
                .background(userGender == "Female" ? .pink.opacity(0.2) : .blue)
                .cornerRadius(200)
                
                Text(userName)
                    .fontWeight(.semibold)
                    .font(.system(size: 18))
            }
            
            VStack(spacing: 0) {
                // Name Row
                HStack {
                    Text("Name")
                        .font(.system(size: 16))
                    Spacer()
                    TextField("Enter your name", text: $userName)
                        .foregroundColor(.gray)
                        .font(.system(size: 16))
                        .multilineTextAlignment(.trailing)
                }
                .padding()
                .background(Color.white)
                
                Divider()
                    .padding(.leading)
                HStack {
                    Text("Age")
                        .font(.system(size: 16))
                    Spacer()
                    TextField("Enter your age", value: $userAge, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.trailing)
                        .font(.system(size: 16))
                }
                .padding()
                .background(Color.white)
                Divider()
                    .padding(.leading)
                
                // Gender Row
                HStack {
                    Text("Gender")
                        .font(.system(size: 16))
                    Spacer()
                    Picker("Select Gender", selection: $userGender) {
                        ForEach(genders, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(MenuPickerStyle()) // Menampilkan opsi sebagai menu
                    .foregroundColor(.gray)
                    .font(.system(size: 16))
                }
                .padding()
                .background(Color.white)
            }
            .background(Color(UIColor.systemGroupedBackground)) // Sesuaikan dengan latar belakang
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.brown, lineWidth: 1) // Border warna coklat
            )
            .padding()
            
            Spacer()
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    presentationMode.wrappedValue.dismiss()  // Menutup halaman dan kembali ke halaman sebelumnya
                }
            }
        }
    }
}
