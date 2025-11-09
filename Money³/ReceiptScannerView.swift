//
//  ReceiptScannerView.swift
//  Finance
//
//  Created by user on 9/11/25.
//


import SwiftUI
import PhotosUI
import Vision
import UIKit

struct ReceiptScannerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var vm = ReceiptScannerViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let image = vm.selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                        .cornerRadius(12)
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                        .frame(height: 300)
                        .overlay {
                            VStack {
                                Image(systemName: "doc.text.viewfinder")
                                    .font(.system(size: 60))
                                    .foregroundStyle(.gray)
                                Text("Select a receipt image")
                                    .foregroundStyle(.secondary)
                            }
                        }
                }
                
                PhotosPicker(selection: $vm.selectedItem, matching: .images) {
                    Label("Choose Photo", systemImage: "photo")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundStyle(.white)
                        .glassEffect(.clear.tint(.blue.opacity(0.5)))
                }
                .padding(.horizontal)
                .onChange(of: vm.selectedItem) { _, _ in
                    Task {
                        await vm.loadImage()
                    }
                }
                
                if vm.isProcessing {
                    ProgressView("Scanning receipt...")
                        .padding()
                }
                
                if !vm.extractedText.isEmpty {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Extracted Text:")
                                .font(.headline)
                            Text(vm.extractedText)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .frame(maxHeight: 150)
                    .padding(.horizontal)
                }
                
                if let error = vm.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.caption)
                        .padding()
                }
                
                Spacer()
                
                if vm.selectedImage != nil && !vm.isProcessing {
                    Button {
                        Task {
                            await vm.scanAndProcess(context: context)
                            if vm.processingComplete {
                                dismiss()
                            }
                        }
                    } label: {
                        Text("Process Receipt")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal)
                    .buttonStyle(.glassProminent)
                    .tint(.green.opacity(0.5))
                }
            }
            .padding()
            .navigationTitle("Scan Receipt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
