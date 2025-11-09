import SwiftUI

enum ExpenseInputType: String {
    case voiceInput, receiptScanner, manualEntry
    
    var systemImage: String {
        switch self {
        case .voiceInput:
            return "waveform"
        case .receiptScanner:
            return "doc.text.viewfinder"
        case .manualEntry:
            return "square.and.pencil"
        }
    }
    
    var label: String {
        switch self {
        case .voiceInput:
            return "Voice"
        case .receiptScanner:
            return "Receipt"
        case .manualEntry:
            return "Manual"
        }
    }
    
    var duration: CGFloat {
        switch self {
        case .voiceInput:
            return 0.3
        case .receiptScanner:
            return 0.4
        case .manualEntry:
            return 0.5
        }
    }
    
    var tintColor: Color {
        return .white
    }
    
    func offset(expanded: Bool) -> CGSize {
        guard expanded else {
            return .zero
        }
        
        switch self {
        case .voiceInput:
            return offset(atIndex: 0, expanded: expanded)
        case .receiptScanner:
            return offset(atIndex: 1, expanded: expanded)
        case .manualEntry:
            return offset(atIndex: 2, expanded: expanded)
        }
    }
    
    private func offset(atIndex index: Int, expanded: Bool) -> CGSize {
        let radius: CGFloat = 120
        let startAngleDeg = -180.0
        let step = 90.0 / Double(3 - 1)
        
        let angleDeg = startAngleDeg + (Double(index) * step)
        let angleRad = angleDeg * .pi / 180
        
        let x = cos(angleRad) * radius
        let y = sin(angleRad) * radius
        
        return CGSize(width: x, height: y)
    }
}
