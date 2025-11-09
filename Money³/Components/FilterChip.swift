import SwiftUI

struct FilterChip: View {
    let title: String
    var icon: String?
    var color: Color = .blue
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.colorScheme) private var scheme
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.headline)
                }
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .foregroundStyle(scheme == .dark ? .white : color)
        }
        .glassEffect(.clear.tint(color.opacity(0.3)).interactive())
    }
}
