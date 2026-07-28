//
//  AccessibilityLanguage.swift
//  A09_C3
//
//  Created by Dina on 22/07/26.
//

import SwiftUI

struct SpeechLocale: ViewModifier {
    let identifier: String
    func body(content: Content) -> some View {
        content.environment(\.locale, Locale(identifier: identifier))
    }
}

extension View {
    func spokenIn(_ identifier: String) -> some View {
        modifier(SpeechLocale(identifier: identifier))
    }
}
