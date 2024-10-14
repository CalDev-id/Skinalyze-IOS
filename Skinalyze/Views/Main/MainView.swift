//
//  MainView.swift
//  Skinalyze
//
//  Created by Ali Haidar on 10/14/24.
//

import SwiftUI

struct MainView: View {
    @State private var selection = 0
    @State private var showCameraScan = false
    @State private var path: [String] = []
    
    var body: some View {
        TabView(selection: $selection) {
            NavigationStack(path: $path) {
                LogView()
                    .navigationBarTitle("FaceLog")
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationDestination(for: String.self) { view in
                        if view == "CameraScanView" {
                            CameraScanView(path: $path)
                        } else if view == "ResultView" {
                            ResultView(path: $path)
                        }
                    }
            }
            .tabItem {
                Image(systemName: "face.smiling")
                Text("FaceLog")
            }
            .tag(0)
            
            NavigationStack {
                EmptyView()
                NavigationLink(destination: CameraScanView(path: $path)) {
                    Text("Open Camera Scan")
                }
            }
            .tabItem {
                Image(systemName: "barcode.viewfinder")
                Text("Scan")
            }
            .tag(1)
            
            .onAppear {
                self.showCameraScan = true
            }
            .navigationDestination(isPresented: $showCameraScan) {
                NavigationView {
                    CameraScanView(path: $path)
                        .navigationBarHidden(true)
                        .onDisappear {
                            self.selection = 0
                        }
                }
            }
            
            NavigationView {
                ProfileView()
                    .navigationBarTitle("Profile")
            }
            .tabItem {
                Image(systemName: "person")
                Text("Profile")
            }
            .tag(2)
        }
    }
}


#Preview {
    MainView()
}
