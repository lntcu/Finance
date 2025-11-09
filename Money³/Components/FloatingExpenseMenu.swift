import SwiftUI

struct FloatingExpenseMenu: View {
    @State private var isExpanded = false
    @Namespace var glassNamespace
    
    @Binding var showingVoiceInput: Bool
    @Binding var showingReceiptScanner: Bool
    @Binding var showingManualEntry: Bool
    
    var body: some View {
        GlassEffectContainer {
            ZStack {
                button(type: .voiceInput)
                button(type: .receiptScanner)
                button(type: .manualEntry)
                
                Button {
                    withAnimation {
                        isExpanded.toggle()
                    }
                } label: {
                    Label("Menu", systemImage: "plus.circle.fill")
                        .labelStyle(.iconOnly)
                        .frame(width: 60, height: 60)
                        .foregroundColor(.white)
                }
                .glassEffect(.regular.tint(.blue).interactive())
                .glassEffectID("menu", in: glassNamespace)
            }
        }
        .padding(32)
    }
    
    private func button(type: ExpenseInputType) -> some View {
        return Button {
            switch type {
            case .voiceInput:
                showingVoiceInput = true
            case .receiptScanner:
                showingReceiptScanner = true
            case .manualEntry:
                showingManualEntry = true
            }
            withAnimation {
                isExpanded = false
            }
        } label: {
            Label(type.label, systemImage: type.systemImage)
                .labelStyle(.iconOnly)
                .frame(width: 60, height: 60)
                .foregroundColor(.gray)
                .opacity(isExpanded ? 1 : 0)
        }
        .glassEffect(.regular.tint(type.tintColor.opacity(0.8)).interactive())
        .glassEffectID(type.label, in: glassNamespace)
        .offset(type.offset(expanded: isExpanded))
        .animation(.spring(duration: type.duration, bounce: 0.2), value: isExpanded)
    }
}

#Preview {
    FloatingExpenseMenu(showingVoiceInput: .constant(false),
                        showingReceiptScanner: .constant(false),
                        showingManualEntry: .constant(false))
}
