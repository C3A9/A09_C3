//
//  PantauanViewModel.swift
//  A09_C3
//
//  Created by Richie Daryl Kwenandar on 18/07/26.
//

import SwiftData
import Observation
import Foundation

@Observable
final class PantauanViewModel {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func add(date: Date, body: String) throws {
        let trimmedBody = body.trimmingCharacters(in: .whitespacesAndNewlines)

        let pantauan = PantauanModel(
            pantauanDate: date,
            pantauanBody: trimmedBody
        )
        modelContext.insert(pantauan)
        try modelContext.save()
        pushIfShared(pantauan)   // BARU
    }

    func update(_ pantauan: PantauanModel, date: Date, body: String) throws {
        let trimmedBody = body.trimmingCharacters(in: .whitespacesAndNewlines)

        pantauan.pantauanDate = date
        pantauan.pantauanBody = trimmedBody
        pantauan.pantauanUpdatedAt = .now

        try modelContext.save()
        pushIfShared(pantauan)   // BARU
    }

    func delete(_ pantauan: PantauanModel) {
        let isOwner = pantauan.careGroup?.isOwner ?? true
        modelContext.delete(pantauan)
        try? modelContext.save()
        Task { await ShareSyncService.shared.deleteRemote(pantauan, isOwner: isOwner) }
    }

    func fetchAll() -> [PantauanModel] {
        let descriptor = FetchDescriptor<PantauanModel>(
            sortBy: [SortDescriptor(\.pantauanDate, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    // BARU — helper, dipakai add dan update
    private func pushIfShared(_ pantauan: PantauanModel) {
        guard let careGroup = try? modelContext.fetch(FetchDescriptor<CareGroupModel>()).first else {
            return
        }

        Task { @MainActor in
            do {
                try await ShareSyncService.shared.push(
                    pantauan,
                    isOwner: careGroup.isOwner
                )
            } catch {
                print("🔴 [SYNC] Gagal push Pantauan \(pantauan.id): \(error)")
            }
        }
    }
}
