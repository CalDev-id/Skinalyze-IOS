//
//  OnboardingChatView.swift
//  Skinalyze
//
//  Created by Heical Chandra on 09/10/24.
//

import SwiftUI

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let role: ChatRole
}

enum ChatRole {
    case system, user
}

struct ChatView: View {
//    init() {
//        let appearance = UINavigationBarAppearance()
//        appearance.configureWithOpaqueBackground()
//        appearance.backgroundColor = UIColor.atas // Warna background navigasi
//        appearance.titleTextAttributes = [.foregroundColor: UIColor.black] // Warna teks title
//        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
//        
//        UINavigationBar.appearance().standardAppearance = appearance
//        UINavigationBar.appearance().scrollEdgeAppearance = appearance
//        UINavigationBar.appearance().compactAppearance = appearance
//        UINavigationBar.appearance().tintColor = .white // Warna item navigasi
//    }
    
    @State private var messages: [ChatMessage] = [
        ChatMessage(text: "Hello! Welcome to Skinalyze. Please tell us about yourself so we can get to know you better 😊", role: .system),
        ChatMessage(text: "What's your name?", role: .system),
        ChatMessage(text: "Asking for your name helps us personalize profile. Don't worry, your privacy is important to us and we'll keep your details safe 😉", role: .system)
    ]
    
    @State private var inputText: String = ""
    @State private var inputAge: Int? = nil // Store integer for age input
    @State private var currentQuestionIndex = 0
    @State private var showLoading: Bool = false
    @State private var showOptions: Bool = true

    @AppStorage("userName") private var userName: String = ""
    @AppStorage("userAge") private var userAge: Int = 0 // Change to Int
    @AppStorage("userGender") private var userGender: String = ""
    @AppStorage("skinType") private var skinType: String = ""
    @AppStorage("skinSensitivity") private var skinSensitivity: String = ""
    @AppStorage("useSkincare") private var useSkincare: String = ""
    
    @State private var scrollToBottom: Bool = false

    var body: some View {
        VStack {
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        Color(.white.opacity(0.0))
                            .frame(height: 10)
                        ForEach(messages) { message in
                            HStack {
                                if message.role == .system {
                                    Image("Maskot")
                                        .resizable()
                                        .frame(width: 50, height: 40)
                                    Text(message.text)
                                        .padding(.horizontal)
                                        .padding(.vertical, 12)
                                        .background(Color.white)
                                        .cornerRadius(20)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                                } else {
                                    Text(message.text)
                                        .padding(.horizontal)
                                        .padding(.vertical, 12)
                                        .background(.brownPrimary)
                                        .cornerRadius(20)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                }
                            }
                            .padding(.trailing)
                            .id(message.id) // Beri ID untuk scroll ke posisi ini
                        }
                        
                        if showLoading {
                            TypingIndicator()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 10)
                                .id("typingIndicator")
                        }
                        
//                        Spacer().frame(height: 100)
                    }
                    Color(.white.opacity(0.0))
                        .frame(height: 50)
                }
                .scrollIndicators(.hidden)
                .padding(.horizontal)
                .padding(.bottom, -10)
                .onChange(of: messages.count) { _ in
                    // Jika ada opsi yang muncul, scroll ke bawah
                    if showOptions {
                        withAnimation {
                            scrollViewProxy.scrollTo("options", anchor: .bottom)
                        }
                    } else if showLoading {
                        withAnimation {
                            scrollViewProxy.scrollTo("typingIndicator", anchor: .bottom)
                        }
                    } else if let lastMessage = messages.last {
                        withAnimation {
                            scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }

            }
            
            
            if currentQuestionIndex == 0, showOptions {
                HStack {
                    HStack {
                        TextField("Please type your answer here...", text: $inputText)
                            .padding(12)
                            .background(Color.white)
                        Button(action: {
                            handleUserInput(inputText)
                        }) {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(.gray)
                                .padding(10)
                                .padding(.horizontal)
                        }
                    }
                    .background(.white)
                    .cornerRadius(30)
                    .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                }
                .padding()
                .background(.brownPrimary)
            } else if currentQuestionIndex == 1, showOptions {
                HStack {
                    HStack {
                        TextField("Enter your age", value: $inputAge, format: .number) // Accept integer input
                            .keyboardType(.numberPad) // Only numeric input
                            .padding(12)
                            .background(Color.white)
                        Button(action: {
                            if let age = inputAge {
                                handleUserInput(String(age)) // Convert integer to string
                            }
                        }) {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(.gray)
                                .padding(10)
                                .padding(.horizontal)
                        }
                    }
                    .background(.white)
                    .cornerRadius(30)
                    .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                }
                .padding()
                .background(.brownPrimary)
            } else if currentQuestionIndex == 2, showOptions { // Gender
                VStack(spacing: 10) {
                    Button(action: {
                        handleUserInput("Female")
                    }) {
                        Text("Female")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(20)
                            .foregroundColor(.black)
                            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                    }

                    Button(action: {
                        handleUserInput("Male")
                    }) {
                        Text("Male")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(20)
                            .foregroundColor(.black)
                            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                    }
                }
                .padding(20)
                .background(.brownPrimary)

            } else if currentQuestionIndex == 3, showOptions {
                VStack(spacing: 10) {
                    Button(action: {
                        handleUserInput("Dry")
                    }) {
                        Text("Dry. Dry skin often feels tight and look flaky")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(20)
                            .foregroundColor(.black)
                            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                    }

                    Button(action: {
                        handleUserInput("Oily")
                    }) {
                        Text("Oily. Oily skin is shiny all over face with large pores")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(20)
                            .foregroundColor(.black)
                            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                    }
                    Button(action: {
                        handleUserInput("Combination")
                    }) {
                        Text("Combination. Combination skin looks shiny in some ares (T-zone) and feel tight on other areas")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(20)
                            .foregroundColor(.black)
                            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                    }
                }
                .padding(20)
                .background(.brownPrimary)

            } else if currentQuestionIndex == 4, showOptions { // Skin Sensitivity
                VStack(spacing: 10) {
                    Button(action: {
                        handleUserInput("Very Sensitive")
                    }) {
                        Text("Very Sensitive. Often reacts with redness, itching, or stinging when try new products")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(20)
                            .foregroundColor(.black)
                            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                    }

                    Button(action: {
                        handleUserInput("Only Sometimes")
                    }) {
                        Text("Only Sometimes. Can handle most products, but sometimes experience irritation")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(20)
                            .foregroundColor(.black)
                            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                    }
                    Button(action: {
                        handleUserInput("Not Sensitive")
                    }) {
                        Text("Not Sensitive. Rarely reacts to new products")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(20)
                            .foregroundColor(.black)
                            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                    }
                }
                .padding(20)
                .background(.brownPrimary)
            } else if currentQuestionIndex == 5, showOptions { // Use Skincare
                VStack(spacing: 10) {
                    NavigationLink(destination:ProductUsedView()){
                        Text("Yes")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(20)
                            .foregroundColor(.black)
                            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                    }
                    NavigationLink(destination:ProductUsedView()){
                        Text("No")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(20)
                            .foregroundColor(.black)
                            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                    }
                }
                .padding(20)
                .background(.brownPrimary)
            }
        }
        .navigationTitle("Skinalyze")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func handleUserInput(_ input: String) {
        messages.append(ChatMessage(text: input, role: .user))
        inputText = ""
        showOptions = false
        showLoading = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showLoading = false
            processInput(input)
        }
    }
    
    func processInput(_ input: String) {
        switch currentQuestionIndex {
        case 0:
            userName = input
            askNextQuestion("How old are you?")
            askNextQuestion("We will make sure to compare your skin condition with others in your same age group.")
        case 1:
            if let age = Int(input) {
                userAge = age
                askNextQuestion("What is your gender?")
                askNextQuestion("We will recommend you the most suitable ingredients based on your profile.")
            }
        case 2:
            userGender = input
            askNextQuestion("What's your skin type?")
        case 3:
            skinType = input
            askNextQuestion("How sensitive is your skin?")
        case 4:
            skinSensitivity = input
            askNextQuestion("Do you use skincare in your daily routine?")
//        case 5:
//            useSkincare = input
//            goToNextPage()
        default:
            break
        }
        
        currentQuestionIndex += 1
        showOptions = true
    }
    
    func askNextQuestion(_ question: String) {
        withAnimation {
            messages.append(ChatMessage(text: question, role: .system))
        }
    }
    
    func goToNextPage() {
        print("User Data: \(userName), \(userAge), \(userGender), \(skinType), \(skinSensitivity), \(useSkincare)")
        // Navigasi ke halaman berikutnya
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChatView()
        }
    }
}

//extension

struct RoundedCornerShape: Shape {
    var corners: UIRectCorner
    var radius: CGFloat

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}


struct TypingIndicator: View {
    @State private var firstDot = false
    @State private var secondDot = false
    @State private var thirdDot = false

    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(Color.gray)
                .frame(width: 10, height: 10)
                .scaleEffect(firstDot ? 1 : 0.5)
                .animation(Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: firstDot)
            Circle()
                .fill(Color.gray)
                .frame(width: 10, height: 10)
                .scaleEffect(secondDot ? 1 : 0.5)
                .animation(Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true).delay(0.2), value: secondDot)
            Circle()
                .fill(Color.gray)
                .frame(width: 10, height: 10)
                .scaleEffect(thirdDot ? 1 : 0.5)
                .animation(Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true).delay(0.4), value: thirdDot)
        }
        .onAppear {
            firstDot = true
            secondDot = true
            thirdDot = true
        }
    }
}
