//
//  CapturedImagesView.swift
//  FaceTracking
//
//  Created by Ali Haidar on 10/3/24.
//

import SwiftUI

struct CapturedImagesView: View {
    @Binding var path: [String]
    let images: [UIImage]
    
    @State private var moveToAnalyze: Bool = false

    var body: some View {
        VStack {
            Text("Captured Images")
                .font(.title)
                .padding()
            
            HStack {
                ForEach(images, id: \.self) { image in
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .padding()
                }
            }
            
            Button("Lanjutkan") {
//                path.append("ResultView")
                moveToAnalyze.toggle()
            }
            
            Button("Selfie Ulang") {
                
            }
        }
        .navigationDestination(isPresented: $moveToAnalyze){
            ResultView(path: $path, images: images)
//            AnalyzeView(selectedImages: images)
        }
    }
}


