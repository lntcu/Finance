import SwiftUI
import Charts

struct CategoryDonutChart: View {
    let expenses: [Expense]

    private var totals: [CategoryTotal] {
        let grouped = Dictionary(grouping: expenses) { $0.category }
        return grouped.map { cat, exps in
            let total = exps.reduce(0) { $0 + $1.amount }
            let category = ExpenseCategory(rawValue: cat) ?? .other
            return CategoryTotal(name: cat, amount: total, color: category.color)
        }
        .sorted { $0.amount > $1.amount }
    }


    private var totalAmount: Double {
        totals.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Spending by Category")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)

            Chart(totals) { total in
                SectorMark(
                    angle: .value("Amount", total.amount),
                    innerRadius: .ratio(0.65),
                    angularInset: 2.0
                )
                .foregroundStyle(total.color)
                .cornerRadius(10.0)
                .annotation(position: .overlay) {
                    if totalAmount > 0, total.amount / totalAmount >= 0.06 {
                        Text("$\(total.amount, specifier: "%.0f")")
                            .font(.headline)
                            .foregroundStyle(.white)
                    }
                }
            }
            .frame(height: 220)
            .padding(.horizontal)
            .padding(.bottom, 4)
        }
    }
}
