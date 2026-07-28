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

    private var itemLimit: Int {
        family == .systemLarge ? 5 : 3
    }

    private var displayedItems: [ObatWidgetItem] {
        Array(entry.items.prefix(itemLimit))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            segmentedTab

            if displayedItems.isEmpty {
                Text("Belum ada obat di kategori ini")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 8)
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(displayedItems.enumerated()), id: \.element.id) { index, item in
                        rowView(for: item)

                        if index < displayedItems.count - 1 {
                            Divider()
                        }
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .padding()
        .widgetURL(URL(string: "a09c3://obat"))
    }

    // MARK: - Segmented Tab
    private var segmentedTab: some View {
        HStack(spacing: 0) {
            segmentButton(title: "Obat Rutin", kategori: .rutin)
            segmentButton(title: "Obat Kondisional", kategori: .kondisional)
        }
        .padding(2)
        .background(Color(.systemGray5))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    @ViewBuilder
    private func segmentButton(title: String, kategori: KategoriObatPilihan) -> some View {
        let isSelected = entry.selectedKategori == kategori

        Button(intent: SelectKategoriIntent(kategori: kategori)) {
            Text(title)
                .font(.caption.weight(.medium))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(isSelected ? 0.15 : 0), radius: 1, y: 0.5)
                .opacity(isSelected ? 1 : 0)
        )
        .foregroundStyle(isSelected ? .primary : .secondary)
    }

    // MARK: - Row per kategori
    @ViewBuilder
    private func rowView(for item: ObatWidgetItem) -> some View {
        if entry.selectedKategori == .kondisional {
            VStack(alignment: .leading, spacing: 2) {
                Text(item.nama)
                    .font(.subheadline)
                if let kondisi = item.kondisiDetail, !kondisi.isEmpty {
                    Text("Kondisi: \(kondisi)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
            .padding(.vertical, 6)
        } else {
            HStack {
                Text(item.nama)
                    .font(.subheadline)
                Spacer()
                Text(item.frekuensi)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            .padding(.vertical, 6)
        }
    }
}
