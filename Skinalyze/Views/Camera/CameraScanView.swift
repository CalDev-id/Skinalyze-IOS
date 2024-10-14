//
//  CameraScanView.swift
//  Skinalyze
//
//  Created by Ali Haidar on 10/9/24.
//

import SwiftUI
import AVFoundation
import Vision
import ARKit
import SceneKit

let synthesizer = AVSpeechSynthesizer()

struct CameraScanView: View {
    
    @Binding var path: [String]
    
    @StateObject private var viewModel = FaceTrackingViewModel()
    @State private var capturedImages: [UIImage] = []
    @State private var currentCaptureStep: Int = 0
    @State private var showCapturedImagesView = false
    @State private var countdown: Int = 3 // Countdown starts at 3
    @State private var isCountdownActive: Bool = false // To track if countdown is active
    @State private var timer: Timer?
    
    @State private var isCameraLoaded = false
    @State private var showLoadingSheet = true
    
    var body: some View {
        ZStack {
            // Full-screen camera view
            //            CameraPreviewView(session: viewModel.session)
            //                .edgesIgnoringSafeArea(.all)
            //
            //            ARViewContainer()
            //                .edgesIgnoringSafeArea(.all)
            
            if isCameraLoaded {
                CameraPreviewView(session: viewModel.session)
                    .edgesIgnoringSafeArea(.all)
                
                
                
                VStack {
                    GeometryReader { geometry in
                        let screenSize = geometry.size
                        let ovalWidth: CGFloat = 350 // Adjust oval width
                        let ovalHeight: CGFloat = 450 // Adjust oval height
                        
                        Ellipse()
                            .stroke(viewModel.isFaceInCircle ? Color.white : Color.red, lineWidth: 4)
                            .frame(width: ovalWidth, height: ovalHeight)
                            .position(x: screenSize.width / 2, y: screenSize.height / 2)
                    }
                }
                
                VStack {
                    Text(
                        viewModel.faceDistanceStatus == "Too Far" ? "TERLALU JAUH" :
                            viewModel.faceOrientation == "No face detected" ? "Posisikan wajah anda di\narea lingkaran" :
                            viewModel.lightingCondition == "dark" ? "TERLALU GELAP" : ""
                    )
                    if viewModel.faceDistanceStatus == "Normal" && viewModel.lightingCondition == "normal" {
                        if capturedImages.count < 1 && viewModel.faceOrientation == "Facing Forward" {
                            Text("Bersiap Memotret")
                        } else if capturedImages.count == 1 && viewModel.faceOrientation == "Facing Right" {
                            Text("Bersiap Memotret")
                        } else if capturedImages.count == 2 && viewModel.faceOrientation == "Facing Left" {
                            Text("Bersiap Memotret")
                        }
                    }
                    if viewModel.faceOrientation != "No face detected"{
                        
                        if capturedImages.count < 1 && viewModel.faceOrientation != "Facing Forward" {
                            Text("LIHAT KEDEPAN")
                        } else if capturedImages.count == 1 && viewModel.faceOrientation != "Facing Right" {
                            Text("LIHAT KEKIRI")
                        } else if capturedImages.count == 2 && viewModel.faceOrientation != "Facing Left" {
                            Text("LIHAT KEKANAN")
                        }
                    }
                    Spacer()
                }
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.top, 80)
                
                // Display lighting and face orientation status
                VStack {
                    HStack {
                        Spacer()
                        Text("PENCAHAYAAN")
                            .font(.system(size: 12))
                            .foregroundColor(viewModel.lightingCondition == "normal" ? Color.green : Color.red)
                            .padding(10)
                            .background(viewModel.lightingCondition == "normal" ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                            .overlay(
                                RoundedRectangle(cornerRadius: 0)
                                    .stroke(viewModel.lightingCondition == "normal" ? Color.green : Color.red, lineWidth: 2)
                            )
                        Spacer()
                        Text("POSISI WAJAH")
                            .font(.system(size: 12))
                            .foregroundColor(viewModel.faceDistanceStatus == "Normal" ? Color.green : Color.red)
                            .padding(10)
                            .background(viewModel.faceDistanceStatus == "Normal" ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                            .overlay(
                                RoundedRectangle(cornerRadius: 0)
                                    .stroke(viewModel.faceDistanceStatus == "Normal" ? Color.green : Color.red, lineWidth: 2)
                            )
                        Spacer()
                        VStack {
                            // Display current capture step
                            if capturedImages.count < 1 {
                                Text("LIHAT DEPAN")
                                    .font(.system(size: 12))
                                    .foregroundColor(viewModel.faceOrientation == "Facing Forward" ? Color.green : Color.red)
                                    .padding(10)
                                    .background(viewModel.faceOrientation == "Facing Forward" ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 0)
                                            .stroke(viewModel.faceOrientation == "Facing Forward" ? Color.green : Color.red, lineWidth: 2)
                                    )
                            } else if capturedImages.count == 1 {
                                Text("LIHAT KIRI")
                                    .font(.system(size: 12))
                                    .foregroundColor(viewModel.faceOrientation == "Facing Right" ? Color.green : Color.red)
                                    .padding(10)
                                    .background(viewModel.faceOrientation == "Facing Right" ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 0)
                                            .stroke(viewModel.faceOrientation == "Facing Right" ? Color.green : Color.red, lineWidth: 2)
                                    )
                            } else {
                                Text("LIHAT KANAN")
                                    .font(.system(size: 12))
                                    .foregroundColor(viewModel.faceOrientation == "Facing Left" ? Color.green : Color.red)
                                    .padding(10)
                                    .background(viewModel.faceOrientation == "Facing Left" ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 0)
                                            .stroke(viewModel.faceOrientation == "Facing Left" ? Color.green : Color.red, lineWidth: 2)
                                    )
                            }
                        }
                        Spacer()
                    }
                    .padding()
                    .background(.black.opacity(0.8))
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        // Circle indicators for captured images
                        Image(systemName: capturedImages.count > 0 ? "circle.fill" : "circle")
                            .resizable()
                            .foregroundColor(capturedImages.count > 0 ? .green : .white)
                            .frame(width: 50, height: 50)
                        Spacer()
                        Image(systemName: capturedImages.count > 1 ? "circle.fill" : "circle")
                            .resizable()
                            .foregroundColor(capturedImages.count > 1 ? .green : .white)
                            .frame(width: 50, height: 50)
                        Spacer()
                        Image(systemName: capturedImages.count > 2 ? "circle.fill" : "circle")
                            .resizable()
                            .foregroundColor(capturedImages.count > 2 ? .green : .white)
                            .frame(width: 50, height: 50)
                        Spacer()
                    }
                    .padding()
                    .background(.black.opacity(0.8))
                }
                
                // Timer Overlay
                if isCountdownActive {
                    Text("\(countdown)")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding()
                }
            } else {
                Color.black.edgesIgnoringSafeArea(.all)
            }
        }
        .onAppear {
//            viewModel.startSession() // Start the camera session
//            startCaptureProcess() // Start the capture process
        }
        .onDisappear {
            viewModel.stopSession() // Stop the camera session
            timer?.invalidate() // Stop the timer when the view disappears
            
        }
        .navigationDestination(isPresented: $showCapturedImagesView) {
            
            CapturedImagesView(path: $path, images: capturedImages)
        }
        
        .sheet(isPresented: $showLoadingSheet) {
            VStack {
                Spacer()
                Button(action: {
                    viewModel.startSession() 
                    startCaptureProcess()
                    self.showLoadingSheet = false
                    self.viewModel.startSession() // Start the camera session
                    self.isCameraLoaded = true
                }) {
                    Text("Load Camera")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
        .onAppear {
            self.showLoadingSheet = true
        }
        
    }
    
    func triggerHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
    }
    
    func speech(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer.speak(utterance)
    }
    
    func startCaptureProcess() {
        
        speech("Look forward")
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.0, repeats: true) { _ in
            if viewModel.faceDistanceStatus == "Normal" && viewModel.lightingCondition == "normal" {
                switch currentCaptureStep {
                case 0:
                    if viewModel.faceOrientation == "Facing Forward" {
                        triggerHapticFeedback()
                        startCountdown(for: .facingForward) // Start countdown for forward orientation
                    }
                case 1:
                    if viewModel.faceOrientation == "Facing Right" {
                        triggerHapticFeedback()
                        startCountdown(for: .facingRight) // Start countdown for right orientation
                    }
                case 2:
                    if viewModel.faceOrientation == "Facing Left" {
                        triggerHapticFeedback()
                        startCountdown(for: .facingLeft) // Start countdown for left orientation
                    }
                default:
                    break
                }
            }
        }
    }
    
    func startCountdown(for orientation: FaceOrientation) {
        guard !isCountdownActive else { return } // Cegah countdown ganda
        isCountdownActive = true
        countdown = 3 // Reset countdown
        
        // Countdown loop dengan pengecekan kondisi setiap detik
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if viewModel.faceDistanceStatus == "Normal" && viewModel.lightingCondition == "normal" {
                switch orientation {
                case .facingForward:
                    if viewModel.faceOrientation != "Facing Forward" {
                        timer.invalidate()
                        isCountdownActive = false
                        return
                    }
                case .facingRight:
                    if viewModel.faceOrientation != "Facing Right" {
                        timer.invalidate()
                        isCountdownActive = false
                        path.append("ResultView")
                        return
                    }
                case .facingLeft:
                    if viewModel.faceOrientation != "Facing Left" {
                        timer.invalidate()
                        isCountdownActive = false
                        return
                    }
                }
                
                countdown -= 1 // Kurangi countdown setiap detik
                if countdown == 0 {
                    timer.invalidate() // Hentikan timer setelah countdown selesai
                    captureImage(for: orientation) // Capture image setelah countdown selesai
                    isCountdownActive = false // Sembunyikan countdown
                }
            } else {
                // Jika kondisi tidak memenuhi, hentikan countdown
                timer.invalidate()
                isCountdownActive = false
            }
        }
    }
    
    
    
    func captureImage(for orientation: FaceOrientation) {
        if let sampleBuffer = viewModel.lastSampleBuffer {
            if let capturedImage = captureImage(from: sampleBuffer) {
                capturedImages.append(capturedImage)
            }
        }
        currentCaptureStep += 1 // Move to the next capture step
        
        switch currentCaptureStep {
        case 1:
            speech("Look left")
        case 2:
            speech("Look right")
        default:
            break
        }
        
        // If we are done capturing all three orientations, navigate to the results view
        if currentCaptureStep > 2 {
            timer?.invalidate() // Stop the main capture timer
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                showCapturedImagesView = true // Show captured images view
            }
        }
    }
    
    //    func captureImage(from sampleBuffer: CMSampleBuffer) -> UIImage? {
    //        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
    //            return nil
    //        }
    //
    //        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
    //        let context = CIContext()
    //
    //        // Rotate the image to match the screen orientation
    //        let image = ciImage.oriented(.right)
    //
    //        if let cgImage = context.createCGImage(image, from: image.extent) {
    //            return UIImage(cgImage: cgImage)
    //        }
    //
    //        return nil
    //    }
    
    func captureImage(from sampleBuffer: CMSampleBuffer) -> UIImage? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return nil
        }
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        
        // Rotate the image to match the screen orientation
        let image = ciImage.oriented(.right)
        
        // Calculate the cropping rectangle based on the oval's size and position
        let screenSize = UIScreen.main.bounds.size
        let ovalWidth: CGFloat = 350
        let ovalHeight: CGFloat = 450
        let circleCenter = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        let cropRect = CGRect(
            x: circleCenter.x - (ovalWidth / 2),
            y: circleCenter.y - (ovalHeight / 2),
            width: ovalWidth,
            height: ovalHeight
        )
        
        // Convert the cropRect to the image's coordinate system
        let scale = CGAffineTransform(scaleX: image.extent.width / screenSize.width, y: image.extent.height / screenSize.height)
        let transformedCropRect = cropRect.applying(scale)
        
        // Crop the image
        let croppedImage = image.cropped(to: transformedCropRect)
        
        // Convert the CIImage to UIImage
        if let cgImage = context.createCGImage(croppedImage, from: croppedImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        
        return nil
    }
    
}

enum FaceOrientation {
    case facingForward
    case facingRight
    case facingLeft
}




struct CameraView: UIViewRepresentable {
    var session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let layer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            layer.frame = uiView.bounds
        }
    }
}

struct CameraPreviewView: UIViewControllerRepresentable {
    var session: AVCaptureSession
    
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = CameraPreviewController()
        controller.session = session
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // No need to update anything here for this simple preview
    }
}

class CameraPreviewController: UIViewController {
    var session: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let session = session else {
            return
        }
        
        // Setup the preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.frame = view.bounds
        if let previewLayer = previewLayer {
            view.layer.addSublayer(previewLayer)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Adjust the preview layer size when the view's layout changes
        previewLayer?.frame = view.bounds
    }
}


