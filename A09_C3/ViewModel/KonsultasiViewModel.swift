//
//  KonsultasiViewModel.swift
//  A09_C3
//
//  Created by Dina on 17/07/26.
//

import Foundation
import SwiftData

enum KonsultasiValidationError: Error {
    case emptyDokter
    case emptyBody
    case namaDokterSimbol
}

class KonsultasiViewModel {
    private let modelContext: ModelContext
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func isValidDokterName(_ name: String) -> Bool {
        let allowedCharacters = CharacterSet.letters
            .union(.whitespaces)
            .union(CharacterSet(charactersIn: ".,"))
        return name.unicodeScalars.allSatisfy { allowedCharacters.contains($0) }
    }
    
    func addKonsultasi(namaDokter: String, tanggal: Date, content: String) throws {
        guard !namaDokter.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw KonsultasiValidationError.emptyDokter
        }
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw KonsultasiValidationError.emptyBody
        }
        
        let konsultasi = KonsulModel(
            namaDokter: namaDokter,
            tanggalKonsultasi: tanggal,
            content: content
        )
        modelContext.insert(konsultasi)
        try modelContext.save()
        pushIfShared(konsultasi)
    }
    
    func update(_ konsultasi: KonsulModel, namaDokter: String, tanggal: Date, content: String) throws {
        guard !namaDokter.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw KonsultasiValidationError.emptyDokter
        }
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw KonsultasiValidationError.emptyBody
        }
        
        konsultasi.namaDokter = namaDokter
        konsultasi.tanggalKonsultasi = tanggal
        konsultasi.content = content
        
        try modelContext.save()
        pushIfShared(konsultasi)
    }
    
    func fetchAll() -> [KonsulModel] {
        let descriptor = FetchDescriptor<KonsulModel>(
            sortBy: [SortDescriptor(\.tanggalKonsultasi, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    func delete(_ konsultasi: KonsulModel) {
        let isOwner = konsultasi.careGroup?.isOwner ?? true
        modelContext.delete(konsultasi)
        try? modelContext.save()
        Task { await ShareSyncService.shared.deleteRemote(konsultasi, isOwner: isOwner) }
    }
    
    private func pushIfShared(_ konsultasi: KonsulModel) {
        guard let careGroup = try? modelContext.fetch(FetchDescriptor<CareGroupModel>()).first else {
            return
        }
        
        Task { @MainActor in
            do {
                try await ShareSyncService.shared.push(
                    konsultasi,
                    isOwner: careGroup.isOwner
                )
            } catch {
                print("🔴 [SYNC] Gagal push Pantauan \(konsultasi.id): \(error)")
            }
        }
    }
}
