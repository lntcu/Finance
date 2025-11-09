//
//  VoiceInputViewModel.swift
//  Finance
//
//  Created by user on 9/11/25.
//

import Speech
import SwiftData
import FoundationModels


@Observable
class VoiceInputViewModel {
    var isRecording = false
    var transcription = ""
    var errorMessage: String?
    var isProcessing = false
    var processingComplete = false
    
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine: AVAudioEngine?
    
    func requestPermissions() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                if status != .authorized {
                    self.errorMessage = "Speech recognition not authorized"
                }
            }
        }
        
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                if !granted {
                    self.errorMessage = "Microphone access not granted"
                }
            }
        }
    }
    
    func startRecording() {
        errorMessage = nil
        transcription = ""
        
        speechRecognizer = SFSpeechRecognizer()
        audioEngine = AVAudioEngine()
        
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            errorMessage = "Speech recognition not available"
            return
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        recognitionRequest.shouldReportPartialResults = true
        
        let inputNode = audioEngine!.inputNode
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self.transcription = result.bestTranscription.formattedString
                }
            }
            if error != nil {
                self.stopRecording()
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        audioEngine!.prepare()
        do {
            try audioEngine!.start()
            isRecording = true
        } catch {
            errorMessage = "Could not start audio engine"
        }
    }
    
    func stopRecording() {
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        isRecording = false
    }
    
    func cleanup() {
        stopRecording()
        recognitionTask = nil
        recognitionRequest = nil
        audioEngine = nil
        speechRecognizer = nil
    }
    
    func processWithAI(context: ModelContext) async {
        guard !transcription.isEmpty else { return }
        isProcessing = true
        errorMessage = nil
        switch SystemLanguageModel.default.availability {
        case .available:
            do {
                let session = LanguageModelSession(instructions: """
                    You are a financial assistant helping users track their expenses.
                    Extract expense information from natural language descriptions.
                    Categorize expenses into: Food, Transport, Shopping, Entertainment, Utilities, Health, Education, or Other.
                    If payment method is not mentioned, default to Cash.
                    """)
                let response = try await session.respond(
                    to: "Extract expense details: \(transcription)",
                    generating: ExtractedExpense.self
                )
                let extracted = response.content
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
                
            } catch {
                errorMessage = "AI processing failed: \(error.localizedDescription)"
            }
            
        case .unavailable(_):
            if let expense = parseExpensePattern(from: transcription) {
                context.insert(expense)
                try? context.save()
                processingComplete = true
            } else {
                errorMessage = "Could not extract expense information"
            }
        }
        
        isProcessing = false
    }
    private func parseExpensePattern(from text: String) -> Expense? {
        let lower = text.lowercased()
        let amountPattern = #"\$?(\d+\.?\d*)"#
        guard let amountMatch = lower.range(of: amountPattern, options: .regularExpression),
              let amount = Double(lower[amountMatch].replacingOccurrences(of: "$", with: "")) else {
            return nil
        }
        var category = ExpenseCategory.other
        if lower.contains("food") || lower.contains("lunch") || lower.contains("dinner") || lower.contains("restaurant") || lower.contains("groceries") {
            category = .food
        } else if lower.contains("uber") || lower.contains("taxi") || lower.contains("transport") || lower.contains("gas") || lower.contains("bus") {
            category = .transport
        } else if lower.contains("shopping") || lower.contains("clothes") || lower.contains("store") {
            category = .shopping
        } else if lower.contains("movie") || lower.contains("entertainment") || lower.contains("concert") {
            category = .entertainment
        } else if lower.contains("electricity") || lower.contains("water") || lower.contains("utilities") || lower.contains("bill") {
            category = .utilities
        } else if lower.contains("doctor") || lower.contains("medicine") || lower.contains("health") || lower.contains("hospital") {
            category = .health
        } else if lower.contains("book") || lower.contains("course") || lower.contains("education") || lower.contains("tuition") {
            category = .education
        }
        return Expense(
            amount: amount,
            category: category.rawValue,
            desc: text,
            date: Date()
        )
    }
}
