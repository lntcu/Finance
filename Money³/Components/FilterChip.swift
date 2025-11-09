import SwiftUI

struct FilterChip: View {
    let title: String
    var icon: String?
    var color: Color = .blue
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption)
                }
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .foregroundStyle(.white)
            .cornerRadius(20)
        }
        .buttonStyle(.glassProminent)
        .tint(isSelected ? color.opacity(0.5) : .gray.opacity(0.5))
    }
}
