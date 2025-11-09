//
//  FilterChip.swift
//  Finance
//
//  Created by user on 9/11/25.
//

import SwiftUI
import SwiftData

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
            .foregroundStyle(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
        .buttonStyle(.glassProminent)
        .tint(isSelected ? color.opacity(0.5) : .gray.opacity(0.5))
    }
}
