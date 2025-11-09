import FoundationModels
import Foundation
import SwiftUI

@Generable
struct ExtractedExpense {
    @Guide(description: "The monetary amount spent, as a decimal number without currency symbols")
    let amount: Double
    
    @Guide(description: "Category of expense. Must be one of: Food, Transport, Shopping, Entertainment, Utilities, Health, Education, Other")
    let category: String
    
    @Guide(description: "Brief description of what was purchased or spent on")
    let description: String
    
    @Guide(description: "Payment method used. Should be one of: Cash, Credit Card, Debit Card, Digital Wallet")
    let paymentMethod: String
}

enum ExpenseCategory: String, CaseIterable {
    case food = "Food"
    case transport = "Transport"
    case shopping = "Shopping"
    case entertainment = "Entertainment"
    case utilities = "Utilities"
    case health = "Health"
    case education = "Education"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .food: return "fork.knife"
        case .transport: return "car.fill"
        case .shopping: return "cart.fill"
        case .entertainment: return "tv.fill"
        case .utilities: return "bolt.fill"
        case .health: return "heart.fill"
        case .education: return "book.fill"
        case .other: return "questionmark.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .food: return .orange
        case .transport: return .blue
        case .shopping: return .purple
        case .entertainment: return .pink
        case .utilities: return .yellow
        case .health: return .red
        case .education: return .green
        case .other: return .gray
        }
    }
}
