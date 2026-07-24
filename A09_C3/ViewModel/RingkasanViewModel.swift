//
//  RingkasanViewModel.swift
//  A09_C3
//
//  Created by Muhammad Dzakki Abdullah on 22/07/26.
//

import Observation
import Foundation

@Observable
final class RingkasanViewModel {
    private let service: RingkasanService

    var poinPantauan: [String] = []
    var poinKonsultasi: [String] = []
    var isGeneratingPantauan = false
    var isGeneratingKonsultasi = false
    var errorPantauan: String?
    var errorKonsultasi: String?
    var lastUpdatedPantauan: Date?
    var lastUpdatedKonsultasi: Date?

    private var pantauanCache: [UUID: CachedPoin]
    private var konsultasiCache: [UUID: CachedPoin]

    var isModelAvailable: Bool { service.isModelAvailable }

    init(service: RingkasanService) {
        self.service = service
        pantauanCache = RingkasanStorage.loadPantauanCache()
        konsultasiCache = RingkasanStorage.loadKonsultasiCache()
    }

    // AC: Dipanggil saat halaman dibuka — TIDAK generate, cuma tampilkan cache yang sudah ada
    func loadCachedDisplay(pantauanList: [PantauanModel], konsulList: [KonsulModel]) {
        let terbaruPantauan = Array(pantauanList.prefix(3))
        poinPantauan = terbaruPantauan.compactMap { pantauanCache[$0.id]?.text }
        lastUpdatedPantauan = terbaruPantauan.compactMap { pantauanCache[$0.id]?.generatedAt }.max()

        let terbaruKonsultasi = Array(konsulList.prefix(3))
        poinKonsultasi = terbaruKonsultasi.compactMap { konsultasiCache[$0.id]?.text }
        lastUpdatedKonsultasi = terbaruKonsultasi.compactMap { konsultasiCache[$0.id]?.generatedAt }.max()
    }

    // AC: Dipanggil lewat pull-to-refresh — HANYA generate catatan yang belum ada di cache
    func generateSemuaRingkasan(pantauanList: [PantauanModel], konsulList: [KonsulModel]) async {
        async let pantauan: Void = generatePantauanIfNeeded(list: Array(pantauanList.prefix(3)))
        async let konsultasi: Void = generateKonsultasiIfNeeded(list: Array(konsulList.prefix(3)))
        _ = await (pantauan, konsultasi)
    }

    private func generatePantauanIfNeeded(list: [PantauanModel]) async {
        isGeneratingPantauan = true
        defer { isGeneratingPantauan = false }
        errorPantauan = nil

        guard !list.isEmpty else {
            poinPantauan = []
            errorPantauan = "Belum ada catatan pantauan untuk diringkas"
            return
        }

        do {
            for item in list {
                let teksSekarang = "\(item.pantauanDate.formatted(date: .abbreviated, time: .omitted)): \(item.pantauanBody)"

                // Generate ulang HANYA kalau belum ada di cache, ATAU teksnya sudah beda
                // dari saat terakhir diringkas (berarti catatan sudah diedit)
                let perluGenerate: Bool
                if let cached = pantauanCache[item.id] {
                    perluGenerate = cached.sourceText != teksSekarang
                } else {
                    perluGenerate = true
                }

                if perluGenerate {
                    let poin = try await service.generatePoinPantauan(catatan: teksSekarang)
                    pantauanCache[item.id] = CachedPoin(
                        sourceText: teksSekarang,
                        text: poin,
                        generatedAt: Date()
                    )
                }
            }
            RingkasanStorage.savePantauanCache(pantauanCache)

            poinPantauan = list.compactMap { pantauanCache[$0.id]?.text }
            lastUpdatedPantauan = list.compactMap { pantauanCache[$0.id]?.generatedAt }.max()
        } catch {
            errorPantauan = "Gagal membuat ringkasan pantauan"
        }
    }

    private func generateKonsultasiIfNeeded(list: [KonsulModel]) async {
        isGeneratingKonsultasi = true
        defer { isGeneratingKonsultasi = false }
        errorKonsultasi = nil

        guard !list.isEmpty else {
            poinKonsultasi = []
            errorKonsultasi = "Belum ada catatan konsultasi untuk diringkas"
            return
        }

        do {
            for item in list {
                let teksSekarang = "\(item.tanggalKonsultasi.formatted(date: .abbreviated, time: .omitted)) - dr. \(item.namaDokter): \(item.content)"

                let perluGenerate: Bool
                if let cached = konsultasiCache[item.id] {
                    perluGenerate = cached.sourceText != teksSekarang
                } else {
                    perluGenerate = true
                }

                if perluGenerate {
                    let poin = try await service.generatePoinKonsultasi(catatan: teksSekarang)
                    konsultasiCache[item.id] = CachedPoin(
                        sourceText: teksSekarang,
                        text: poin,
                        generatedAt: Date()
                    )
                }
            }
            RingkasanStorage.saveKonsultasiCache(konsultasiCache)

            poinKonsultasi = list.compactMap { konsultasiCache[$0.id]?.text }
            lastUpdatedKonsultasi = list.compactMap { konsultasiCache[$0.id]?.generatedAt }.max()
        } catch {
            errorKonsultasi = "Gagal membuat ringkasan konsultasi"
        }
    }
}
