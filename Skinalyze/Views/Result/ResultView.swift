//
//  ResultView.swift
//  FaceTracking
//
//  Created by Ali Haidar on 10/4/24.
//

import SwiftUI
import Vision
import CoreML
import SwiftData

struct ResultView: View {
    
    @Binding var path: [String]
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var result: [Result]
    
    @State var images: [UIImage] = []
    @State var selectedCardIndex = 0
    @State var analyzedImages: [UIImage] = []
    @State private var isLoading = false
    
    // Dictionary to store counts of each acne type
    @State private var acneCounts: [String: Int] = [
        "blackheads": 0,
        "dark spot": 0,
        "nodules": 0,
        "papules": 0,
        "pustules": 0,
        "whiteheads": 0
    ]
    
    // GEA scale state
    @State private var geaScale = 1
    
    @State private var currentDate = Date()
    
    var body: some View {
        VStack {
            HStack(alignment: .center){
                
                
                Text(currentDate, format: .dateTime.day().month().year())
                    .font(.headline)
                    .padding(.bottom)
                Text("at")
                
                Text(currentDate, format: .dateTime.hour().minute())
                    .font(.headline)
                    .padding(.bottom)
            }
            
            
            if isLoading {
                ProgressView("Analyzing Images...")
            } else if !analyzedImages.isEmpty {
                CardStackView(images: analyzedImages, selectedCardIndex: $selectedCardIndex, imageSize: CGSize(width: 330, height: 430))
            } else if !images.isEmpty {
                CardStackView(images: images, selectedCardIndex: $selectedCardIndex, imageSize: CGSize(width: 330, height: 430))
                    .onAppear {
                        analyzeImages()
                    }
            } else {
                Text("No images available")
            }
            
            // Display counts for each acne type
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(acneCounts.keys.sorted(), id: \.self) { key in
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .overlay(
                                Text("\(key.capitalized) (\(acneCounts[key] ?? 0))")
                                    .font(.footnote)
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                            )
                            .frame(width: 180, height: 40)
                    }
                }
                .padding(.horizontal, 16)
            }
            
            // Display the GEA Scale
            //            Text("Acne Severity Level (GEA Scale): \(geaScale)")
            //                .foregroundStyle(.purple)
            let severityLevel = AcneSeverityLevel(rawValue: geaScale)!
            SeverityIndicator(acneLevelScale: geaScale, severityLevel: severityLevel.description)
            
            Button("Refresh") {
                analyzeImages()
            }
            .padding()
            .buttonBorderShape(.capsule)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    // Call the save function here
                    saveData()
                }
            }
        }
    }
    
    func saveData() {
        let imagesBase64 = images.compactMap { $0.base64 }
        let analyzedImagesBase64 = analyzedImages.compactMap { $0.base64 }
            
        let result = Result(
            images: imagesBase64,
            selectedCardIndex: selectedCardIndex,
            analyzedImages: analyzedImagesBase64,
            isLoading: isLoading,
            acneCounts: acneCounts,
            geaScale: geaScale,
            currentDate: currentDate
        )
        
        // Insert the result into the model context
        modelContext.insert(result)
        
        // Save the model context
        do {
            path.removeAll()
            try modelContext.save()
            print("Data saved successfully!")
        } catch {
            print("Error saving data: \(error.localizedDescription)")
        }
    }
    
    func analyzeImages() {
        analyzedImages.removeAll()
        isLoading = true
        resetAcneCounts() // Reset counts before new analysis
        
        let dispatchGroup = DispatchGroup()
        
        for image in images {
            dispatchGroup.enter()
            detectObjects(in: image) {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.isLoading = false
            self.calculateGEAScale() // Calculate the GEA Scale after detection
        }
    }
    
    func resetAcneCounts() {
        acneCounts = [
            "blackheads": 0,
            "dark spot": 0,
            "nodules": 0,
            "papules": 0,
            "pustules": 0,
            "whiteheads": 0
        ]
    }
    
    func detectObjects(in image: UIImage, completion: @escaping () -> Void) {
        let inputSize = CGSize(width: 224, height: 224)
        
        guard let resizedImage = image.resized(to: inputSize),
              let ciImage = CIImage(image: resizedImage) else {
            print("Failed to resize image or convert UIImage to CIImage")
            completion()
            return
        }
        
        let config = MLModelConfiguration()
        guard let model = try? VNCoreMLModel(for: acneObj28200(configuration: config).model) else {
            print("Failed to load model")
            completion()
            return
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            if let error = error {
                print("Error in CoreML request: \(error.localizedDescription)")
                completion()
                return
            }
            
            if let results = request.results as? [VNRecognizedObjectObservation] {
                DispatchQueue.main.async {
                    let analyzedImage = drawBoundingBoxes(on: image, results: results, originalImageSize: image.size)
                    self.analyzedImages.append(analyzedImage)
                    self.updateAcneCounts(with: results) // Update counts based on detected results
                    completion()
                }
            } else {
                completion()
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("Failed to perform image request: \(error.localizedDescription)")
            completion()
        }
    }
    
    func updateAcneCounts(with results: [VNRecognizedObjectObservation]) {
        for result in results {
            let label = result.labels.first?.identifier.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? "unknown"
            //            print("Detected label: \(label)")  // Debugging output
            
            // Increment count for the detected label, ensuring case insensitivity
            if let _ = acneCounts[label] {
                acneCounts[label, default: 0] += 1
            }
        }
    }
    
    
    // GEA Scale calculation logic based on detected acne counts
    func calculateGEAScale() {
        let papulesCount = acneCounts["papules"] ?? 0
        let pustulesCount = acneCounts["pustules"] ?? 0
        let nodulesCount = acneCounts["nodules"] ?? 0
        let blackheadsCount = acneCounts["blackhead"] ?? 0
        let whiteheadsCount = acneCounts["whiteheads"] ?? 0
        
        if nodulesCount > 5 || pustulesCount > 10 {
            // Stage 4 (Very Severe Acne) or Stage 5 (Extremely Severe Acne)
            geaScale = nodulesCount > 10 || pustulesCount > 15 ? 5 : 4
        } else if pustulesCount > 5 || papulesCount > 10 {
            // Stage 3 (Severe Acne)
            geaScale = 3
        } else if papulesCount > 5 || blackheadsCount > 10 || whiteheadsCount > 10 {
            // Stage 2 (Moderate Acne)
            geaScale = 2
        } else {
            // Stage 1 (Mild Acne)
            geaScale = 1
        }
    }
    
    
    func drawBoundingBoxes(on image: UIImage, results: [VNRecognizedObjectObservation], originalImageSize: CGSize) -> UIImage {
        let imageSize = originalImageSize
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 1.0)
        
        // Draw the original image
        image.draw(in: CGRect(origin: .zero, size: imageSize))
        
        // Set up the context for drawing bounding boxes
        guard let context = UIGraphicsGetCurrentContext() else { return image }
        
        context.setLineWidth(9.0)
        
        // Define color mapping for each label
        let labelColorMapping: [String: UIColor] = [
            "blackheads": UIColor.cyan,
            "dark spot": UIColor.blue,
            "nodules": UIColor.red,
            "papules": UIColor.orange,
            "pustules": UIColor.green,
            "whiteheads": UIColor.gray,
        ]
        
        for result in results {
            let boundingBox = result.boundingBox
            
            // Get the label and confidence
            let label = result.labels.first?.identifier ?? "Unknown"
            let confidence = result.labels.first?.confidence ?? 0.0
            
            // Select the color based on the label
            let color = labelColorMapping[label, default: UIColor.black]
            
            // Set the stroke color for the bounding box
            context.setStrokeColor(color.cgColor)
            
            // Convert the bounding box to the original image's coordinate system (flipping the y-axis)
            let rect = CGRect(
                x: boundingBox.minX * imageSize.width,
                y: (1 - boundingBox.minY - boundingBox.height) * imageSize.height,
                width: boundingBox.width * imageSize.width,
                height: boundingBox.height * imageSize.height
            )
            
            // Draw the bounding box
            context.stroke(rect)
            
            // Draw the label text with the same color
            let labelText = "\(label) (\(Int(confidence * 100))%)"
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 30),
                .foregroundColor: color,
                .backgroundColor: UIColor.white
            ]
            
            // Determine where to draw the label
            let textSize = labelText.size(withAttributes: attributes)
            let labelRect = CGRect(
                x: rect.origin.x,
                y: rect.origin.y - textSize.height, // Position above the bounding box
                width: textSize.width,
                height: textSize.height
            )
            
            // Draw the label text in the image
            //            labelText.draw(in: labelRect, withAttributes: attributes)
        }
        
        // Get the new image with bounding boxes and labels
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? image
    }
}

//#Preview {
//    ResultView(images: [UIImage(named: "imgTest")!])
//}

// Helper function to resize the image
extension UIImage {
    func resized(to targetSize: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}



