//
//  SelectKategoriIntent.swift
//  ObatWidgetExtension
//
//  Created by Muhammad Dzakki Abdullah on 27/07/26.
//

import AppIntents
import WidgetKit

struct SelectKategoriIntent: AppIntent {
    static var title: LocalizedStringResource = "Pilih Kategori Obat"

    @Parameter(title: "Kategori")
    var kategori: KategoriObatPilihan

    init() {
        self.kategori = .rutin
    }

    init(kategori: KategoriObatPilihan) {
        self.kategori = kategori
    }

    func perform() async throws -> some IntentResult {
        await MainActor.run {
            SharedDefaults.selectedKategori = kategori
        }
        WidgetCenter.shared.reloadTimelines(ofKind: "ObatWidget")
        return .result()
    }
}
