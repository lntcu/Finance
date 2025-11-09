//
//  ManualEntryView.swift
//  Finance
//
//  Created by user on 9/11/25.
//


import SwiftUI
import SwiftData

struct ManualEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    @State private var amount = ""
    @State private var selectedCategory = ExpenseCategory.other
    @State private var description = ""
    @State private var date = Date()
    @State private var paymentMethod = "Cash"
    @State private var showingError = false
    
    let paymentMethods = ["Cash", "Credit Card", "Debit Card", "Digital Wallet"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Amount") {
                    HStack {
                        Text("$")
                            .font(.title2)
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                            .font(.title2)
                    }
                }
                
                Section("Category") {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(ExpenseCategory.allCases, id: \.self) { category in
                            HStack {
                                Image(systemName: category.icon)
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }
                
                Section("Details") {
                    TextField("Description", text: $description)
                    
                    DatePicker("Date", selection: $date, displayedComponents: [.date])
                    
                    Picker("Payment Method", selection: $paymentMethod) {
                        ForEach(paymentMethods, id: \.self) { method in
                            Text(method).tag(method)
                        }
                    }
                }
                
                Section {
                    Button {
                        saveExpense()
                    } label: {
                        Text("Save Expense")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.white)
                    }
                    .listRowBackground(Color.blue)
                    .disabled(amount.isEmpty)
                }
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert("Invalid Amount", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please enter a valid amount")
            }
        }
    }
    
    private func saveExpense() {
        guard let amountValue = Double(amount), amountValue > 0 else {
            showingError = true
            return
        }
        
        let expense = Expense(
            amount: amountValue,
            category: selectedCategory.rawValue,
            desc: description.isEmpty ? selectedCategory.rawValue : description,
            date: date,
            paymentMethod: paymentMethod
        )
        
        context.insert(expense)
        try? context.save()
        dismiss()
    }
}
