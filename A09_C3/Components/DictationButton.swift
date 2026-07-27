//
//  DictationButton.swift
//  A09_C3
//
//  Created by Richie Daryl Kwenandar on 19/07/26.
//

import SwiftUI

struct DictationButton: View {
    @Bindable var dictationManager: DictationManager
    @Binding var text: String
    var onError: ((String) -> Void)? = nil
    
    @State private var baseText: String = ""
    
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var iconSize: CGFloat {
        dynamicTypeSize.isAccessibilitySize ? 30 : 16
    }

    private var buttonSize: CGFloat {
        dynamicTypeSize.isAccessibilitySize ? 50 : 36
    }
    
    var body: some View {
        CircleIconButton(
            systemName: dictationManager.isRecording ? "stop.fill" : "mic.fill",
            iconColor: dictationManager.isRecording ? .white : .primary,
            backgroundColor: dictationManager.isRecording ? .red : Color(.tertiarySystemFill),
            isProminent: dictationManager.isRecording,
            action: {
                Task { await toggleDictation() }
            }
        )
        .accessibilityLabel(dictationManager.isRecording ? "Hentikan dikte" : "Mulai dikte")
        .onChange(of: dictationManager.transcribedText) { _, newValue in
            guard dictationManager.isRecording else { return }
            text = dictationManager.appendTranscription(existingText: baseText, newText: newValue)
        }
        .spokenIn("id_ID")
    }
    
    private func toggleDictation() async {
        if dictationManager.isRecording {
            dictationManager.stopRecording()
        } else {
            baseText = text
            let granted = await dictationManager.requestAuthorization()
            guard granted else {
                onError?("Izin mikrofon/dikte belum diberikan")
                return
            }
            try? dictationManager.startRecording()
        }
    }
}

#Preview {
    @Previewable @State var text = ""
    @Previewable @State var manager = DictationManager()
    
    DictationButton(dictationManager: manager, text: $text)
        .padding()
}
