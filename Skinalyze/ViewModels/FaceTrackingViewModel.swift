//
//  FaceTrackingViewModel.swift
//  FaceTracking
//
//  Created by Ali Haidar on 10/3/24.
//

import SwiftUI
import AVFoundation
import Vision

class FaceTrackingViewModel: NSObject, ObservableObject {
    @Published var faceOrientation: String = "Detecting..."
    @Published var lightingCondition: String = "Lighting Condition: Unknown"
    @Published var isFaceInCircle: Bool = false
    @Published var faceBoundingBox: CGRect = .zero // Menyimpan bounding box wajah untuk digunakan pada oval
    @Published var lastSampleBuffer: CMSampleBuffer?
    
    var session = AVCaptureSession()
    private var faceDetectionRequest = VNDetectFaceRectanglesRequest()
    private let sequenceHandler = VNSequenceRequestHandler()
    
    @Published var faceDistanceStatus: String = "Distance: Normal"
    
    let minFaceWidth: CGFloat = 250
    let maxFaceWidth: CGFloat = 300
    
    override init() {
        super.init()
        configureCamera()
        faceDetectionRequest = VNDetectFaceRectanglesRequest(completionHandler: handleFaceDetection)
    }
    
    func startSession() {
        DispatchQueue.global(qos: .background).async {
            self.session.startRunning()
        }
        
    }
    
    func stopSession() {
        session.stopRunning()
    }
    
    func configureCamera() {
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            session.addInput(input)
            
            try captureDevice.lockForConfiguration()
            captureDevice.exposureMode = .locked
            captureDevice.unlockForConfiguration()
            
        } catch {
            print("Error setting up camera input: \(error)")
        }
        
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        session.addOutput(output)
    }
    
    private func handleFaceDetection(request: VNRequest, error: Error?) {
        guard let results = request.results as? [VNFaceObservation], let face = results.first else {
            DispatchQueue.main.async {
                self.faceOrientation = "No face detected"
                self.isFaceInCircle = false
                self.faceBoundingBox = .zero // Reset bounding box jika tidak ada wajah
            }
            return
        }
        
        let yaw = face.yaw?.doubleValue ?? 0.0
        
        DispatchQueue.main.async {
            if yaw > 0.5 {
                self.faceOrientation = "Facing Left"
            } else if yaw < -0.5 {
                self.faceOrientation = "Facing Right"
            } else {
                self.faceOrientation = "Facing Forward"
            }
            
            // Update bounding box wajah
            self.faceBoundingBox = face.boundingBox
            self.checkIfFaceIsInCircle(boundingBox: face.boundingBox)
        }
    }
    
    private func checkIfFaceIsInCircle(boundingBox: CGRect) {
        let screenSize = UIScreen.main.bounds.size
        let faceRect = CGRect(
            x: boundingBox.origin.x * screenSize.width,
            y: (1 - boundingBox.origin.y - boundingBox.height) * screenSize.height,
            width: boundingBox.width * screenSize.width,
            height: boundingBox.height * screenSize.height
        )
        
        let ovalWidth: CGFloat = 350
        let ovalHeight: CGFloat = 450
        let circleCenter = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        let ovalRect = CGRect(
            x: circleCenter.x - (ovalWidth / 2),
            y: circleCenter.y - (ovalHeight / 2),
            width: ovalWidth,
            height: ovalHeight
        )
        
        // Check if the face is within the oval
        //        if ovalRect.contains(faceRect) {
        //            // If the face is inside the oval, check its size
        //            let faceWidth = faceRect.width
        /////adjust disini --------------------------------------------------------------------------------------
        ////             Define acceptable width range for "Normal"
        //            let normalWidthMin: CGFloat = 180 // Adjust this value as needed
        //            let normalWidthMax: CGFloat = 350 // Adjust this value as needed
        //
        //            // Update distance status based on face width
        //            if faceWidth < normalWidthMin {
        //                self.faceDistanceStatus = "Too Far"
        //                self.isFaceInCircle = false
        //            } else if faceWidth > normalWidthMax {
        //                self.faceDistanceStatus = "Out of Range"
        //                self.isFaceInCircle = false
        //            } else {
        // If the face width is within acceptable range
        self.faceDistanceStatus = "Normal"
        self.isFaceInCircle = true
        //            }
        //        } else {
        //            // If the face is outside the oval, set status to out of range
        //            self.isFaceInCircle = false
        //            self.faceDistanceStatus = "Out of Range"
        //        }
    }
    
    
    
    
    private func calculateAverageLuminance(from pixelBuffer: CVPixelBuffer) -> Float {
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
        
        let buffer = unsafeBitCast(baseAddress, to: UnsafeMutablePointer<UInt8>.self)
        var totalLuminance: Float = 0.0
        
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        
        for row in 0..<height {
            for col in 0..<width {
                let pixelIndex = (row * bytesPerRow) + col * 4
                
                let blue = Float(buffer[pixelIndex])
                let green = Float(buffer[pixelIndex + 1])
                let red = Float(buffer[pixelIndex + 2])
                
                let luminance = 0.299 * red + 0.587 * green + 0.114 * blue
                totalLuminance += luminance
            }
        }
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
        
        let totalPixels = width * height
        return totalLuminance / Float(totalPixels)
    }
}


extension FaceTrackingViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        // Menangani pengenalan wajah
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .leftMirrored, options: [:])
        
        do {
            try imageRequestHandler.perform([faceDetectionRequest])
        } catch {
            print("Failed to perform face detection: \(error)")
        }
        
        // Menghitung luminance rata-rata untuk menentukan kondisi pencahayaan
        let averageLuminance = calculateAverageLuminance(from: pixelBuffer)
        
        DispatchQueue.main.async {
            if averageLuminance > 100 {
                self.lightingCondition = "normal"
            } else {
                self.lightingCondition = "dark"
            }
        }
        
        // Menyimpan sample buffer terakhir untuk diambil gambarnya nanti
        lastSampleBuffer = sampleBuffer
    }
}
