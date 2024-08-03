//
//  ContentView.swift
//  Aayam_FInal_ML_Model
//
//  Created by Aayam on 8/3/24.
//

import SwiftUI
import CoreML
import Vision

struct ContentView: View {
    
    let photoArray = ["car", "banana", "cat", "plane"]
    @State private var message = ""
    @State private var arrayIndex = 0
    @State private var image = UIImage(named: "cat")!
    @State private var confidence: CGFloat = 0
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .cornerRadius(15)
                    .shadow(radius: 10)
                
                Text(message)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(10)
                
                ConfidenceGraph(confidence: confidence)
                    .frame(height: 30)
                    .padding(.horizontal)
                
                Button(action: {
                    useAI(sentImage: photoArray[arrayIndex])
                }) {
                    Text("Analyze Image")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                
                HStack(spacing: 50) {
                    ArrowButton(direction: .backward) {
                        changeImage(direction: .backward)
                    }
                    ArrowButton(direction: .forward) {
                        changeImage(direction: .forward)
                    }
                }
            }
            .padding()
        }
    }
    
    private func changeImage(direction: ImageDirection) {
        switch direction {
        case .forward:
            arrayIndex = (arrayIndex + 1) % photoArray.count
        case .backward:
            arrayIndex = (arrayIndex - 1 + photoArray.count) % photoArray.count
        }
        message = ""
        confidence = 0
        image = UIImage(named: photoArray[arrayIndex])!
    }
    
    func useAI(sentImage: String) {
        guard let imagePath = Bundle.main.path(forResource: sentImage, ofType: "jpg") else {
            message = "Image not found"
            return
        }
        let imageURL = NSURL.fileURL(withPath: imagePath)
        
        let modelFile = try? MobileNetV2(configuration: MLModelConfiguration())
        let model = try! VNCoreMLModel(for: modelFile!.model)
        let handler = VNImageRequestHandler(url: imageURL)
        
        let request = VNCoreMLRequest(model: model, completionHandler: findResults)
        try! handler.perform([request])
    }
    
    func findResults(request: VNRequest, error: Error?) {
        guard let results = request.results as? [VNClassificationObservation] else {
            fatalError("Unable to get results")
        }
        
        var bestGuess = ""
        var bestConfidence: VNConfidence = 0
        
        for classification in results {
            if (classification.confidence > bestConfidence) {
                bestConfidence = classification.confidence
                bestGuess = classification.identifier
            }
        }
        message = "Image is: \(bestGuess)"
        confidence = CGFloat(bestConfidence)
    }
}

enum ImageDirection {
    case forward, backward
}

struct ArrowButton: View {
    let direction: ImageDirection
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: direction == .backward ? "chevron.left" : "chevron.right")
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .clipShape(Circle())
                .shadow(radius: 5)
        }
    }
}

struct ConfidenceGraph: View {
    let confidence: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .cornerRadius(5)
                
                Rectangle()
                    .fill(LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .leading, endPoint: .trailing))
                    .frame(width: geometry.size.width * confidence)
                    .cornerRadius(5)
                
                Text(String(format: "Confidence: %.2f", confidence))
                    .font(.caption)
                    .foregroundColor(.black)
                    .padding(.leading, 5)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
