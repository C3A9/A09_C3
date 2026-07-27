//
//  SearchHistoryRowView.swift
//  A09_C3
//
//  Created by Richie Daryl Kwenandar on 21/07/26.
//

import SwiftUI

struct SearchHistoryRowView: View {
    let item: SearchHistoryItem
    let onSelect: () -> Void
    let onDelete: () -> Void
    
    private var relativeDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.unitsStyle = .full
        return formatter.localizedString(for: item.searchedAt, relativeTo: .now)
    }
    
    var body: some View {
        HStack {
            Button(action: onSelect) {
                HStack {
                    Image(systemName: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                        .foregroundStyle(.secondary)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.query)
                            .foregroundStyle(.primary)
                        Text(relativeDate)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Riwayat pencarian \(item.query)")
            .accessibilityValue("Dicari \(relativeDate)")
            .accessibilityHint("Ketuk dua kali untuk mencari ulang")
            .accessibilityAddTraits(.isButton)
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .foregroundStyle(.gray)
            }
            .buttonStyle(.borderless)
            .accessibilityHint("Ketuk dua kali untuk menghapus dari riwayat")
        }
    }
}

#Preview {
    List {
        SearchHistoryRowView(
            item: SearchHistoryItem(query: "Paracetamol", searchedAt: .now.addingTimeInterval(-86400)),
            onSelect: {},
            onDelete: {}
        )
    }
}
