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
                
                Text("Add Expense")
                    .font(.largeTitle)
                    .fontWeight(.bold)
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
                        .background(.blue.gradient)
                        .foregroundStyle(.white)
                        .cornerRadius(16)
                    }
                    Button {
                        showingReceiptScanner = true
                    } label: {
                        HStack {
                            Image(systemName: "doc.text.viewfinder")
                                .font(.title2)
                            Text("Scan Receipt")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.green.gradient)
                        .foregroundStyle(.white)
                        .cornerRadius(16)
                    }
                    
                    Button {
                        showingManualEntry = true
                    } label: {
                        HStack {
                            Image(systemName: "pencil")
                                .font(.title2)
                            Text("Enter Manually")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.purple.gradient)
                        .foregroundStyle(.white)
                        .cornerRadius(16)
                    }
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
        }
    }
}
