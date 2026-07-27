//
//  ObatWidgetView.swift
//  ObatWidgetExtension
//
//  Created by Muhammad Dzakki Abdullah on 27/07/26.
//

import SwiftUI
import WidgetKit
import AppIntents

struct ObatWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: ObatEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Obat")
                .font(.headline)

            HStack(spacing: 8) {
                tabButton(title: "Rutin", kategori: .rutin)
                tabButton(title: "Kondisional", kategori: .kondisional)
            }

            if entry.items.isEmpty {
                Text("Belum ada obat di kategori ini")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(entry.items.prefix(family == .systemLarge ? 6 : 3))) { item in
                        Text("\(item.nama) — \(item.frekuensi)")
                            .font(.caption)
                            .lineLimit(1)
                    }
                }
            }

            Spacer()
        }
        .padding()
        .widgetURL(URL(string: "a09c3://obat"))
    }

    @ViewBuilder
    private func tabButton(title: String, kategori: KategoriObatPilihan) -> some View {
        let isSelected = entry.selectedKategori == kategori

        Button(intent: SelectKategoriIntent(kategori: kategori)) {
            Text(title)
                .font(.caption.weight(isSelected ? .bold : .regular))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    Capsule().fill(isSelected ? Color.cyan.opacity(0.25) : Color.clear)
                )
                .foregroundStyle(isSelected ? .cyan : .secondary)
        }
        .buttonStyle(.plain)
    }
}
