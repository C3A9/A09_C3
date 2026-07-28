//
//  RingkasanService.swift
//  A09_C3
//
//  Created by Muhammad Dzakki Abdullah on 22/07/26.
//

import FoundationModels
import Translation
import Observation

@Observable
final class RingkasanService {
    private let translationBridge: TranslationBridge

    // Penanda yang diminta ke model kalau catatan tidak bisa ditafsirkan dengan jelas
    private static let unclearMarker = "UNCLEAR_NOTE"

    init(translationBridge: TranslationBridge) {
        self.translationBridge = translationBridge
    }

    var isModelAvailable: Bool {
        SystemLanguageModel.default.availability == .available
    }

    // Satu catatan -> satu poin ringkasan
    func generatePoinPantauan(catatan: String) async throws -> String {
        let catatanEN = try await translationBridge.translate(
            catatan,
            from: Locale.Language(identifier: "id"),
            to: Locale.Language(identifier: "en")
        )

        let instructions = Instructions("""
            You are a caregiver assistant. Rephrase the following single patient monitoring note \
            in simpler words, as ONE short sentence.

            IMPORTANT: Only summarize if the note clearly describes a patient's condition, \
            symptom, or event. Do NOT guess, infer, or invent meaning from unclear, incomplete, \
            or fragmented text (e.g. casual chat fragments, typos, or words that don't form a \
            coherent statement about the patient).

            If the note is unclear or does not contain a clear statement about the patient, \
            respond with EXACTLY this text and nothing else: \(Self.unclearMarker)
            """)

        let session = LanguageModelSession(instructions: instructions)
        let prompt = """
            \(catatanEN)

            Respond with ONLY one short sentence summarizing this note, or "\(Self.unclearMarker)" \
            if the note is unclear. No prefix, no label, no extra text.
            """

        let response = try await session.respond(to: prompt)
        let poinEN = response.content.trimmingCharacters(in: .whitespacesAndNewlines)

        // Kalau model menandai catatan tidak jelas, JANGAN paksa translate hasil karangan
        // model — tampilkan catatan ASLI apa adanya, supaya user tahu ini tulisan mereka sendiri
        guard !poinEN.contains(Self.unclearMarker) else {
            return "Catatan tidak jelas: \"\(catatan)\""
        }

        let poinID = try await translationBridge.translate(
            poinEN,
            from: Locale.Language(identifier: "en"),
            to: Locale.Language(identifier: "id")
        )

        return poinID.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // Satu catatan konsultasi -> satu poin ringkasan
    func generatePoinKonsultasi(catatan: String) async throws -> String {
        let catatanEN = try await translationBridge.translate(
            catatan,
            from: Locale.Language(identifier: "id"),
            to: Locale.Language(identifier: "en")
        )

        let instructions = Instructions("""
            You are a caregiver assistant. Rephrase the following single medical consultation note \
            in simpler words, as ONE short sentence.

            IMPORTANT: Only summarize if the note clearly describes a patient's condition, \
            symptom, or event. Do NOT guess, infer, or invent meaning from unclear, incomplete, \
            or fragmented text (e.g. casual chat fragments, typos, or words that don't form a \
            coherent statement about the patient).

            If the note is unclear or does not contain a clear statement about the patient, \
            respond with EXACTLY this text and nothing else: \(Self.unclearMarker)
            """)

        let session = LanguageModelSession(instructions: instructions)
        let prompt = """
            \(catatanEN)

            Respond with ONLY one short sentence summarizing this note, or "\(Self.unclearMarker)" \
            if the note is unclear. No prefix, no label, no extra text.
            """

        let response = try await session.respond(to: prompt)
        let poinEN = response.content.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !poinEN.contains(Self.unclearMarker) else {
            return "Catatan tidak jelas: \"\(catatan)\""
        }

        let poinID = try await translationBridge.translate(
            poinEN,
            from: Locale.Language(identifier: "en"),
            to: Locale.Language(identifier: "id")
        )

        return poinID.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
