import Foundation
import SwiftData

/// Service for managing expense data operations and analytics
@Observable
final class ExpenseService {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    /// Calculate total spending by category
    func calculateCategoryTotals(from expenses: [Expense]) -> [CategoryTotal] {
        let grouped = Dictionary(grouping: expenses) { $0.category }
        return grouped.map { cat, exps in
            let total = exps.reduce(0) { $0 + $1.amount }
            let category = ExpenseCategory(rawValue: cat) ?? .other
            return CategoryTotal(name: cat, amount: total, color: category.color)
        }.sorted { $0.amount > $1.amount }
    }
    
    /// Get daily spending series for analytics
    func getDailySpendingSeries(from expenses: [Expense]) -> [(Date, Double)] {
        let cal = Calendar.current
        let grouped = Dictionary(grouping: expenses) { cal.startOfDay(for: $0.date) }
        return grouped.map { ($0.key, $0.value.reduce(0) { $0 + $1.amount }) }
            .sorted { $0.0 < $1.0 }
    }
    
    /// Filter expenses by time period
    func getFilteredExpenses(_ expenses: [Expense], period: String) -> [Expense] {
        let cal = Calendar.current
        let now = Date()
        
        switch period {
        case "Week":
            let weekAgo = cal.date(byAdding: .day, value: -7, to: now)!
            return expenses.filter { $0.date >= weekAgo }
        case "Month":
            let monthAgo = cal.date(byAdding: .month, value: -1, to: now)!
            return expenses.filter { $0.date >= monthAgo }
        case "Year":
            let yearAgo = cal.date(byAdding: .year, value: -1, to: now)!
            return expenses.filter { $0.date >= yearAgo }
        default:
            return expenses
        }
    }
    
    /// Save an expense to the database
    func saveExpense(_ expense: Expense) throws {
        modelContext.insert(expense)
        try modelContext.save()
    }
    
    /// Delete an expense from the database
    func deleteExpense(_ expense: Expense) throws {
        modelContext.delete(expense)
        try modelContext.save()
    }
}
