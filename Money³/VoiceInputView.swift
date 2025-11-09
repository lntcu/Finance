//
//  VoiceInputView.swift
//  Finance
//
//  Created by user on 9/11/25.
//


import SwiftUI
import Speech
import AVFoundation

struct VoiceInputView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var vm = VoiceInputViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                ZStack {
                    Circle()
                        .frame(width: 200, height: 200)
                        .scaleEffect(vm.isRecording ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: vm.isRecording)
                        .glassEffect(.clear.tint(vm.isRecording ? Color.red.opacity(0.2) : Color.gray.opacity(0.2)), in: .circle)
                    
                    Image(systemName: "mic.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(vm.isRecording ? .red : .gray)
                }
                Text(vm.isRecording ? "Listening..." : "Tap to speak")
                    .font(.title2)
                    .fontWeight(.semibold)
                if !vm.transcription.isEmpty {
                    ScrollView {
                        Text(vm.transcription)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                    .frame(maxHeight: 150)
                    .padding(.horizontal)
                }
                if vm.isProcessing {
                    ProgressView("Processing with AI...")
                        .padding()
                }
                if let error = vm.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.caption)
                        .padding()
                }
                Spacer()
                Button {
                    if vm.isRecording {
                        vm.stopRecording()
                    } else {
                        vm.startRecording()
                    }
                } label: {
                    Text(vm.isRecording ? "Stop Recording" : "Start Recording")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundStyle(.white)
                }
                .padding(.horizontal)
                .disabled(vm.isProcessing)
                .buttonStyle(.glassProminent)
                .tint(vm.isRecording ? .red.opacity(0.5) : .blue.opacity(0.5))
                Button {
                    Task {
                        await vm.processWithAI(context: context)
                        if vm.processingComplete {
                            dismiss()
                        }
                    }
                } label: {
                    Text("Process & Save")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundStyle(.white)
                }
                .padding(.horizontal)
                .disabled(vm.isProcessing)
                .buttonStyle(.glassProminent)
                .tint(.green.opacity(0.5))
            }
            .padding()
            .navigationTitle("Voice Input")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        vm.cleanup()
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            vm.requestPermissions()
        }
        .onDisappear {
            vm.cleanup()
        }
    }
}
