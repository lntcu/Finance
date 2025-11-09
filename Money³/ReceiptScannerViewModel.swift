//
//  ReceiptScannerViewModel.swift
//  Finance
//
//  Created by user on 9/11/25.
//

import SwiftUI
import Foundation
import _PhotosUI_SwiftUI
import SwiftData
import FoundationModels
import Vision

@Observable
class ReceiptScannerViewModel {
    var selectedItem: PhotosPickerItem?
    var selectedImage: UIImage?
    var extractedText = ""
    var isProcessing = false
    var errorMessage: String?
    var processingComplete = false
    
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
        let text = await performOCR(on: image)
        await MainActor.run {
            extractedText = text
        }
        await processReceiptWithAI(text: text, context: context)
    }
    
    private func processReceiptWithAI(text: String, context: ModelContext) async {
        switch SystemLanguageModel.default.availability {
        case .available:
            do {
                let session = LanguageModelSession(instructions: """
                    You are a receipt parser extracting expense information from OCR text.
                    Find the total amount, merchant name, and categorize the purchase.
                    Categories: Food, Transport, Shopping, Entertainment, Utilities, Health, Education, Other
                    """)
                
                let response = try await session.respond(
                    to: "Extract expense from receipt: \(text)",
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
                
                await MainActor.run {
                    context.insert(expense)
                    try? context.save()
                    processingComplete = true
                    isProcessing = false
                }
                
            } catch {
                await MainActor.run {
                    errorMessage = "AI processing failed: \(error.localizedDescription)"
                    isProcessing = false
                }
            }
            
        case .unavailable:
            let expenses = parseReceiptPattern(text)
            await MainActor.run {
                if !expenses.isEmpty {
                    for expense in expenses {
                        context.insert(expense)
                    }
                    try? context.save()
                    processingComplete = true
                } else {
                    errorMessage = "Could not extract expenses from receipt"
                }
                isProcessing = false
            }
        }
    }
    
    private func performOCR(on image: UIImage) async -> String {
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
    
    private func parseReceiptPattern(_ text: String) -> [Expense] {
        var expenses: [Expense] = []
        let lines = text.components(separatedBy: .newlines)
        let amountPattern = #"\$?(\d+\.?\d{2})"#
        var totalAmount: Double = 0
        var items: [(String, Double)] = []
        for line in lines {
            let lower = line.lowercased()
            if let range = line.range(of: amountPattern, options: .regularExpression) {
                let amountStr = line[range].replacingOccurrences(of: "$", with: "")
                if let amount = Double(amountStr) {
                    let desc = line.replacingOccurrences(of: line[range], with: "").trimmingCharacters(in: .whitespaces)
                    if !desc.isEmpty && amount > 0 {
                        items.append((desc, amount))
                    }
                    if lower.contains("total") || lower.contains("amount") {
                        totalAmount = max(totalAmount, amount)
                    }
                }
            }
        }
        
        if !items.isEmpty {
            for (desc, amount) in items {
                let category = categorizeItem(desc)
                expenses.append(Expense(
                    amount: amount,
                    category: category.rawValue,
                    desc: desc,
                    date: Date()
                ))
            }
        } else if totalAmount > 0 {
            let category = categorizeReceipt(text)
            expenses.append(Expense(
                amount: totalAmount,
                category: category.rawValue,
                desc: "Receipt scan",
                date: Date()
            ))
        }
        return expenses
    }
    
    private func categorizeItem(_ text: String) -> ExpenseCategory {
        let lower = text.lowercased()
        if lower.contains("food") || lower.contains("meal") || lower.contains("coffee") {
            return .food
        } else if lower.contains("gas") || lower.contains("fuel") || lower.contains("parking") {
            return .transport
        }
        
        return .other
    }
    
    private func categorizeReceipt(_ text: String) -> ExpenseCategory {
        let lower = text.lowercased()
        if lower.contains("restaurant") || lower.contains("cafe") || lower.contains("food") {
            return .food
        } else if lower.contains("market") || lower.contains("store") || lower.contains("shop") {
            return .shopping
        } else if lower.contains("gas") || lower.contains("station") {
            return .transport
        }
        
        return .other
    }
}
