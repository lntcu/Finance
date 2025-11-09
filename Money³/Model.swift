//
//  Model.swift
//  Finance
//
//  Created by user on 9/11/25.
//

import Foundation
import SwiftUI

extension DashboardView {
    func getCategoryTotals(from expenses: [Expense]) -> [CategoryTotal] {
        let grouped = Dictionary(grouping: expenses) { $0.category }
        return grouped.map { cat, exps in
            let total = exps.reduce(0) { $0 + $1.amount }
            let category = ExpenseCategory(rawValue: cat) ?? .other
            return CategoryTotal(name: cat, amount: total, color: category.color)
        }.sorted { $0.amount > $1.amount }
    }
    
    func getDailySpending(from expenses: [Expense]) -> [(Date, Double)] {
        let cal = Calendar.current
        let grouped = Dictionary(grouping: expenses) { cal.startOfDay(for: $0.date) }
        return grouped.map { ($0.key, $0.value.reduce(0) { $0 + $1.amount }) }
            .sorted { $0.0 < $1.0 }
    }
    
    func getFilteredExpenses(all expenses: [Expense], period: String) -> [Expense] {
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
}
