import Foundation
import FoundationModels

/// Service for AI-powered expense processing and parsing
final class AIProcessingService {
    
    /// Process expense text with AI and extract structured data
    /// Falls back to pattern-based parsing if AI is unavailable
    func processExpenseText(_ text: String) async -> ExtractedExpense? {
        switch SystemLanguageModel.default.availability {
        case .available:
            return await processWithAI(text)
        case .unavailable(_):
            return parseExpensePattern(from: text)
        }
    }
    
    /// Process receipt text with AI and extract expense information
    func processReceiptText(_ text: String) async -> ExtractedExpense? {
        switch SystemLanguageModel.default.availability {
        case .available:
            return await processReceiptWithAI(text)
        case .unavailable(_):
            return parseReceiptPattern(text)
        }
    }
    
    // MARK: - Private Methods
    
    private func processWithAI(_ text: String) async -> ExtractedExpense? {
        do {
            let session = LanguageModelSession(instructions: """
                You are a financial assistant helping users track their expenses.
                Extract expense information from natural language descriptions.
                Categorize expenses into: Food, Transport, Shopping, Entertainment, Utilities, Health, Education, or Other.
                If payment method is not mentioned, default to Cash.
                """)
            
            let response = try await session.respond(
                to: "Extract expense details: \(text)",
                generating: ExtractedExpense.self
            )
            
            return response.content
        } catch {
            return nil
        }
    }
    
    private func processReceiptWithAI(_ text: String) async -> ExtractedExpense? {
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
            
            return response.content
        } catch {
            return nil
        }
    }
    
    private func parseExpensePattern(from text: String) -> ExtractedExpense? {
        let lower = text.lowercased()
        let amountPattern = #"\$?(\d+\.?\d*)"#
        
        guard let amountMatch = lower.range(of: amountPattern, options: .regularExpression),
              let amount = Double(lower[amountMatch].replacingOccurrences(of: "$", with: "")) else {
            return nil
        }
        
        var category = ExpenseCategory.other
        if lower.contains("food") || lower.contains("lunch") || lower.contains("dinner") || 
           lower.contains("restaurant") || lower.contains("groceries") {
            category = .food
        } else if lower.contains("uber") || lower.contains("taxi") || lower.contains("transport") || 
                  lower.contains("gas") || lower.contains("bus") {
            category = .transport
        } else if lower.contains("shopping") || lower.contains("clothes") || lower.contains("store") {
            category = .shopping
        } else if lower.contains("movie") || lower.contains("entertainment") || lower.contains("concert") {
            category = .entertainment
        } else if lower.contains("electricity") || lower.contains("water") || lower.contains("utilities") || 
                  lower.contains("bill") {
            category = .utilities
        } else if lower.contains("doctor") || lower.contains("medicine") || lower.contains("health") || 
                  lower.contains("hospital") {
            category = .health
        } else if lower.contains("book") || lower.contains("course") || lower.contains("education") || 
                  lower.contains("tuition") {
            category = .education
        }
        
        return ExtractedExpense(
            amount: amount,
            category: category.rawValue,
            description: text,
            paymentMethod: "Cash"
        )
    }
    
    private func parseReceiptPattern(_ text: String) -> ExtractedExpense? {
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
            // Use the first item as primary expense
            if let first = items.first {
                let category = categorizeReceipt(text)
                return ExtractedExpense(
                    amount: first.1,
                    category: category.rawValue,
                    description: first.0,
                    paymentMethod: "Cash"
                )
            }
        } else if totalAmount > 0 {
            let category = categorizeReceipt(text)
            return ExtractedExpense(
                amount: totalAmount,
                category: category.rawValue,
                description: "Receipt scan",
                paymentMethod: "Cash"
            )
        }
        
        return nil
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
