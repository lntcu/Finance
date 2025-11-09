import Foundation
import SwiftData

@Observable
final class VoiceInputViewModel {
    var isProcessing = false
    var processingComplete = false
    var errorMessage: String?
    
    private let speechService = SpeechService()
    private let aiService = AIProcessingService()
    
    var isRecording: Bool {
        get { speechService.isRecording }
        set { speechService.isRecording = newValue }
    }
    
    var transcription: Bool {
        get { speechService.transcription != "" }
        set { }
    }
    
    var transcriptionText: String {
        speechService.transcription
    }
    
    func requestPermissions() {
        speechService.requestPermissions()
    }
    
    func startRecording() {
        speechService.startRecording()
    }
    
    func stopRecording() {
        speechService.stopRecording()
    }
    
    func cleanup() {
        speechService.cleanup()
    }
    
    func processWithAI(context: ModelContext) async {
        guard !speechService.transcription.isEmpty else { return }
        isProcessing = true
        errorMessage = nil
        
        if let extracted = await aiService.processExpenseText(speechService.transcription) {
            let validCategory = ExpenseCategory.allCases
                .first { $0.rawValue == extracted.category }?.rawValue ?? ExpenseCategory.other.rawValue
            
            let expense = Expense(
                amount: extracted.amount,
                category: validCategory,
                desc: extracted.description,
                date: Date(),
                paymentMethod: extracted.paymentMethod
            )
            
            context.insert(expense)
            try? context.save()
            processingComplete = true
        } else {
            errorMessage = "Could not extract expense information"
        }
        
        isProcessing = false
    }
}
