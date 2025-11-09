import SwiftData
import SwiftUI

struct ContentView: View {
    @State private var showingVoiceInput = false
    @State private var showingReceiptScanner = false
    @State private var showingManualEntry = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ExpenseListView()
            
            FloatingExpenseMenu(
                showingVoiceInput: $showingVoiceInput,
                showingReceiptScanner: $showingReceiptScanner,
                showingManualEntry: $showingManualEntry
            )
            .padding(.bottom, 32)
        }
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

#Preview {
    ContentView()
}
