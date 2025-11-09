import Vision
import UIKit

/// Service for performing OCR operations on images
final class OCRService {
    
    /// Perform OCR on an image and extract text
    func performOCR(on image: UIImage) async -> String {
        guard let cgImage = image.cgImage else { return "" }
        
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try handler.perform([request])
            
            guard let observations = request.results else { return "" }
            
            let text = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }.joined(separator: "\n")
            
            return text
        } catch {
            return ""
        }
    }
}
