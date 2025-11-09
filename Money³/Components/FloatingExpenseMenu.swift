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
                    Label("Menu", systemImage: "plus")
                        .font(.title)
                        .labelStyle(.iconOnly)
                        .frame(width: 60, height: 60)
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(isExpanded ? 135 : 0))
                        .animation(.spring(bounce: 0.5), value: isExpanded)
                }
                .sensoryFeedback(.impact, trigger: isExpanded)
                .glassEffect(.clear.tint(.blue.opacity(0.5)).interactive())
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
                .font(.title3)
                .labelStyle(.iconOnly)
                .frame(width: 60, height: 60)
                .opacity(isExpanded ? 1 : 0)
                .foregroundStyle(.secondary)
        }
        .sensoryFeedback(.selection, trigger: showingVoiceInput)
        .sensoryFeedback(.selection, trigger: showingReceiptScanner)
        .sensoryFeedback(.selection, trigger: showingManualEntry)
        .glassEffect(.regular.interactive())
        .glassEffectID(type.label, in: glassNamespace)
        .offset(type.offset(expanded: isExpanded))
        .animation(.spring(duration: type.duration, bounce: 0.5).delay(type.delay), value: isExpanded)
    }
}

#Preview {
    FloatingExpenseMenu(showingVoiceInput: .constant(false),
                        showingReceiptScanner: .constant(false),
                        showingManualEntry: .constant(false))
}
