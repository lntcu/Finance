import SwiftData
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Add", systemImage: "plus.circle.fill") {
                AddExpenseView()
            }

            Tab("Expenses", systemImage: "list.bullet") {
                ExpenseListView()
            }
        }
    }
}
