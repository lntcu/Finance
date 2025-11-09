import SwiftUI

struct ExpenseRow: View {
    let expense: Expense
    
    var category: ExpenseCategory {
        ExpenseCategory(rawValue: expense.category) ?? .other
    }
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Image(systemName: category.icon)
                    .font(.title3)
                    .foregroundStyle(category.color)
                    .padding()
            }
            .glassEffect(.clear.tint(category.color.opacity(0.5)), in: .circle)
            .frame(width: 50, height: 50)
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.desc)
                    .font(.headline)
                    .lineLimit(1)
                
                HStack {
                    Text(expense.category)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("•")
                        .foregroundStyle(.secondary)
                    Text(expense.date.formatted(date: .omitted, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            Text("$\(expense.amount, specifier: "%.2f")")
                .font(.title3)
                .fontWeight(.semibold)
        }
        .padding(.vertical, 4)
    }
}
