//
//  ExpenseListView.swift
//  Finance
//
//  Created by user on 9/11/25.
//


import SwiftUI
import SwiftData

struct ExpenseListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]
    @State private var searchText = ""
    @State private var selectedCategory: ExpenseCategory?
    
    var filteredExpenses: [Expense] {
        var result = expenses
        
        if !searchText.isEmpty {
            result = result.filter { expense in
                expense.desc.localizedCaseInsensitiveContains(searchText) ||
                expense.category.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if let category = selectedCategory {
            result = result.filter { $0.category == category.rawValue }
        }
        
        return result
    }
    
    var groupedExpenses: [(String, [Expense])] {
        let cal = Calendar.current
        let grouped = Dictionary(grouping: filteredExpenses) { expense in
            cal.startOfDay(for: expense.date)
        }
        
        return grouped.sorted { $0.key > $1.key }.map { date, expenses in
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return (formatter.string(from: date), expenses.sorted { $0.date > $1.date })
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        FilterChip(
                            title: "All",
                            isSelected: selectedCategory == nil
                        ) {
                            selectedCategory = nil
                        }
                        ForEach(ExpenseCategory.allCases, id: \.self) { category in
                            FilterChip(
                                title: category.rawValue,
                                icon: category.icon,
                                color: category.color,
                                isSelected: selectedCategory == category
                            ) {
                                if selectedCategory == category {
                                    selectedCategory = nil
                                } else {
                                    selectedCategory = category
                                }
                            }
                        }
                    }
                    .padding()
                }
                
                if filteredExpenses.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "tray")
                            .font(.system(size: 60))
                            .foregroundStyle(.gray)
                        Text("No expenses yet")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("Add your first expense to get started")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    List {
                        ForEach(groupedExpenses, id: \.0) { date, dayExpenses in
                            Section {
                                ForEach(dayExpenses) { expense in
                                    ExpenseRow(expense: expense)
                                }
                                .onDelete { indexSet in
                                    deleteExpenses(at: indexSet, from: dayExpenses)
                                }
                            } header: {
                                HStack {
                                    Text(date)
                                    Spacer()
                                    Text("$\(dayExpenses.reduce(0) { $0 + $1.amount }, specifier: "%.2f")")
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                        
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Expenses")
            .searchable(text: $searchText, prompt: "Search expenses")
        }
    }
    
    private func deleteExpenses(at offsets: IndexSet, from expenses: [Expense]) {
        for index in offsets {
            context.delete(expenses[index])
        }
        try? context.save()
    }
}
