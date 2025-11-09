import Foundation
import SwiftData

@Model
final class Expense {
    var id: UUID
    var amount: Double
    var category: String
    var desc: String
    var date: Date
    var paymentMethod: String
    
    init(amount: Double, category: String, desc: String, date: Date, paymentMethod: String = "Cash") {
        self.id = UUID()
        self.amount = amount
        self.category = category
        self.desc = desc
        self.date = date
        self.paymentMethod = paymentMethod
    }
}
