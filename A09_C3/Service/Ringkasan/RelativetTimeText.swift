//
//  RelativetTimeText.swift
//  A09_C3
//
//  Created by Muhammad Dzakki Abdullah on 22/07/26.
//

import SwiftUI

struct RelativeTimeText: View {
    let date: Date?

    private var formatted: String {
        guard let date else { return "" }
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.unitsStyle = .full
        return "Diperbarui \(formatter.localizedString(for: date, relativeTo: Date()))"
    }

    var body: some View {
        if date != nil {
            Text(formatted)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
