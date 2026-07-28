//
//  ObatWidgetProvider.swift
//  ObatWidgetExtension
//
//  Created by Muhammad Dzakki Abdullah on 27/07/26.
//

import WidgetKit
import SwiftData

struct ObatWidgetItem: Identifiable {
    let id: UUID
    let nama: String
    let dosis: String
    let frekuensi: String
    let kondisiDetail: String?
}

struct ObatEntry: TimelineEntry {
    let date: Date
    let selectedKategori: KategoriObatPilihan
    let items: [ObatWidgetItem]
}

struct ObatWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> ObatEntry {
        ObatEntry(
            date: .now,
            selectedKategori: .rutin,
            items: [
                ObatWidgetItem(id: UUID(), nama: "Paracetamol", dosis: "500", frekuensi: "1 kali sehari, 1 Tablet", kondisiDetail: nil)
            ]
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (ObatEntry) -> Void) {
        completion(fetchEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ObatEntry>) -> Void) {
        let entry = fetchEntry()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: .now) ?? .now
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func fetchEntry() -> ObatEntry {
        let context = ModelContext(SharedModelContainer.container)
        let kategori = SharedDefaults.selectedKategori

        guard let allObat = try? context.fetch(FetchDescriptor<Obat>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )) else {
            return ObatEntry(date: .now, selectedKategori: kategori, items: [])
        }

        let filtered = allObat.filter { obat in
            kategori == .kondisional ? obat.isKondisional : !obat.isKondisional
        }

        let items = filtered.map { obat in
            ObatWidgetItem(
                id: obat.id,
                nama: obat.nama,
                dosis: obat.dosis,
                frekuensi: obat.frekuensi,
                kondisiDetail: obat.kondisiDetail
            )
        }

        return ObatEntry(date: .now, selectedKategori: kategori, items: items)
    }
}
