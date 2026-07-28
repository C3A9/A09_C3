//
//  TranslationBridge.swift
//  A09_C3
//
//  Created by Muhammad Dzakki Abdullah on 22/07/26.
//

import Translation
import Observation

@Observable
final class TranslationBridge {
    private struct Request {
        let text: String
        let source: Locale.Language
        let target: Locale.Language
        let continuation: CheckedContinuation<String, Error>
    }

    var configuration: TranslationSession.Configuration?

    private var queue: [Request] = []
    private var isProcessing = false
    private var activeContinuation: CheckedContinuation<String, Error>?
    private var activeText: String = ""

    func translate(_ text: String, from source: Locale.Language, to target: Locale.Language) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            queue.append(Request(text: text, source: source, target: target, continuation: continuation))
            processNextIfNeeded()
        }
    }

    private func processNextIfNeeded() {
        guard !isProcessing, !queue.isEmpty else { return }
        isProcessing = true
        let next = queue.removeFirst()
        activeContinuation = next.continuation
        activeText = next.text

        if let current = configuration,
           current.source == next.source,
           current.target == next.target {
            // Panggil invalidate() langsung ke property, bukan ke binding lokal 'current'
            configuration?.invalidate()
        } else {
            configuration = TranslationSession.Configuration(source: next.source, target: next.target)
        }
    }

    func handleSession(_ session: TranslationSession) async {
        do {
            let response = try await session.translate(activeText)
            activeContinuation?.resume(returning: response.targetText)
        } catch {
            activeContinuation?.resume(throwing: error)
        }
        activeContinuation = nil
        isProcessing = false
        processNextIfNeeded()
    }
}
