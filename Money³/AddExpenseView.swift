//
//  AddExpenseView.swift
//  Finance
//
//  Created by user on 9/11/25.
//


import SwiftUI
import SwiftData
import Speech
import Vision
import PhotosUI

struct AddExpenseView: View {
    @Environment(\.modelContext) private var context
    @State private var showingVoiceInput = false
    @State private var showingReceiptScanner = false
    @State private var showingManualEntry = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                HStack {
                    Text("Add Expenses")
                        .font(.title.bold())
                        .padding()
                    Spacer()
                }
                VStack(spacing: 20) {
                    Button {
                        showingVoiceInput = true
                    } label: {
                        HStack {
                            Image(systemName: "mic.fill")
                                .font(.title2)
                            Text("Speak Your Expense")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                    .foregroundStyle(.white)
                    .buttonStyle(.glassProminent)
                    .tint(.blue.opacity(0.5))
                    Button {
                        showingReceiptScanner = true
                    } label: {
                        HStack {
                            Image(systemName: "doc.text.viewfinder")
                                .font(.title2)
                            Text("Scan Receipt")
                                .font(.headline)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                    }
                    .foregroundStyle(.white)
                    .buttonStyle(.glassProminent)
                    .tint(.green.opacity(0.5))
                    
                    Button {
                        showingManualEntry = true
                    } label: {
                        HStack {
                            Image(systemName: "pencil")
                                .font(.title2)
                            Text("Enter Manually")
                                .font(.headline)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                    }
                    .foregroundStyle(.white)
                    .buttonStyle(.glassProminent)
                    .tint(.purple.opacity(0.5))
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingVoiceInput) {
                VoiceInputView()
            }
            .sheet(isPresented: $showingReceiptScanner) {
                ReceiptScannerView()
            }
            .sheet(isPresented: $showingManualEntry) {
                ManualEntryView()
            }
            .navigationTitle("Add Expense")
        }
    }
}
