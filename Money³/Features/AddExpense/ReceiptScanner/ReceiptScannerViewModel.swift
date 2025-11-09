import SwiftUI
import Foundation
import _PhotosUI_SwiftUI
import SwiftData

@Observable
class ReceiptScannerViewModel {
    var selectedItem: PhotosPickerItem?
    var selectedImage: UIImage?
    var extractedText = ""
    var isProcessing = false
    var errorMessage: String?
    var processingComplete = false
    
    private let ocrService = OCRService()
    private let aiService = AIProcessingService()
    
    func loadImage() async {
        guard let item = selectedItem else { return }
        
        if let data = try? await item.loadTransferable(type: Data.self),
           let image = UIImage(data: data) {
            await MainActor.run {
                self.selectedImage = image
            }
        }
    }
    
    func scanAndProcess(context: ModelContext) async {
        guard let image = selectedImage else { return }
        await MainActor.run {
            isProcessing = true
            errorMessage = nil
        }
        
        let text = await ocrService.performOCR(on: image)
        await MainActor.run {
            extractedText = text
        }
        
        await processReceiptWithAI(text: text, context: context)
    }
    
    private func processReceiptWithAI(text: String, context: ModelContext) async {
        if let extracted = await aiService.processReceiptText(text) {
            let validCategory = ExpenseCategory.allCases
                .first { $0.rawValue == extracted.category }?.rawValue ?? ExpenseCategory.other.rawValue
            
            let expense = Expense(
                amount: extracted.amount,
                category: validCategory,
                desc: extracted.description,
                date: Date(),
                paymentMethod: extracted.paymentMethod
            )
            
            await MainActor.run {
                context.insert(expense)
                try? context.save()
                processingComplete = true
                isProcessing = false
            }
        } else {
            await MainActor.run {
                errorMessage = "Could not extract expenses from receipt"
                isProcessing = false
            }
        }
    }
}
