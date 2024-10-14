

import SwiftUI

struct ProfileView: View {
    
    @AppStorage("userName") private var userName: String = ""
    @AppStorage("userAge") private var userAge: Int = 0 // Change to Int
    @AppStorage("userGender") private var userGender: String = ""
    @AppStorage("skinType") private var skinType: String = ""
    @AppStorage("skinSensitivity") private var skinSensitivity: String = ""
    @AppStorage("useSkincare") private var useSkincare: String = ""
    
    var body: some View {
            VStack{
                Divider()
                    .padding(.bottom)
                NavigationLink(destination: EditProfileView()) {
                    HStack {
                        Group {
                            Image("Maskot")
                                .resizable()
                                .frame(width: 45, height: 40)
                                .padding()
                        }
                        .background(userGender == "Female" ? .pink.opacity(0.2) : .blue)
                        .cornerRadius(200)
                        .frame(width: 60, height: 60)
                        .padding(.trailing)
                        
                        Text(userName)
                            .fontWeight(.semibold)
                            .font(.system(size: 18))
                        
                        Spacer()
                        
                        Image(systemName: "chevron.forward")
                            .fontWeight(.semibold)
                            .font(.title3)
                    }
                    .padding()
                    .background(Color.profileClr)
                    .cornerRadius(10)
                    .foregroundColor(.black)
                }

                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.brownSecondary, lineWidth: 1)
                )
                .padding(.bottom, 20)

                VStack(alignment:.leading){
                    Text("My Skin")
                        .fontWeight(.semibold)
                        .font(.system(size: 20))
                    VStack(spacing: 0) {
                        // Skin Goals Row
                        HStack {
                            Text("Skin Goals")
                                .font(.system(size: 16))
                            Spacer()
                            Text("Detail")
                                .foregroundColor(.gray)
                                .font(.system(size: 16))
                            Image(systemName: "chevron.forward")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.white)
                        
                        Divider()
                            .padding(.leading)
                        
                        // Skin Type Row
                        HStack {
                            Text("Skin Type")
                                .font(.system(size: 16))
                            Spacer()
                            Text("Detail")
                                .foregroundColor(.gray)
                                .font(.system(size: 16))
                            Image(systemName: "chevron.forward")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.white)
                    }
                    .background(Color(UIColor.systemGroupedBackground)) // Sesuaikan dengan latar belakang
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.brownSecondary, lineWidth: 1) // Border luar abu-abu tipis
                    )
                }
                .padding(.bottom, 20)
                VStack(alignment:.leading){
                    Text("Product Used")
                        .fontWeight(.semibold)
                        .font(.system(size: 20))
                    NavigationLink(destination: ProductUsedView()){
                        VStack(spacing: 0) {
                            HStack {
                                Text("Saved Products")
                                    .font(.system(size: 16))
                                Spacer()
                                Text("Detail")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 16))
                                Image(systemName: "chevron.forward")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.white)
                        }
                        .background(Color(UIColor.systemGroupedBackground)) // Sesuaikan dengan latar belakang
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.brownSecondary, lineWidth: 1) // Border luar abu-abu tipis
                        )
                    }
                }
                Spacer()
            }
            .padding(.horizontal)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            
        }
    }


#Preview {
    NavigationView{
        ProfileView()
    }
}
