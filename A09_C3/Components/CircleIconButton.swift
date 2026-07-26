//
//  CircleIconButton.swift
//  A09_C3
//
//  Created by Dina on 17/07/26.
//

import SwiftUI

struct CircleIconButton: View {
    let systemName: String
    let iconColor: Color
    let backgroundColor: Color
    var size: CGFloat = 45
    var iconSize: CGFloat = 20
    var isEnabled: Bool = true
    var isProminent: Bool = false
    let action: () -> Void
    
    private var foregroundColor: Color {
        isEnabled ? iconColor : .secondary
    }
    
    private var tintColor: Color {
        guard isEnabled else {
            return .gray.opacity(0.12)
        }

        if isProminent {
            return backgroundColor
        }

        return Color.white.opacity(0.01)
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: iconSize))
                .foregroundStyle(foregroundColor)
                .frame(width: size, height: size)
                .contentShape(Circle())
                .glassEffect(
                    .regular
                        .tint(tintColor)
                        .interactive(isEnabled),
                    in: Circle()
                )
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}

#Preview {
    HStack {
        CircleIconButton(
            systemName: "xmark",
            iconColor: .primary,
            backgroundColor: Color.gray.opacity(0.16),
            action: {}
        )
        .accessibilityLabel("Tombol batal")
        CircleIconButton(
            systemName: "checkmark",
            iconColor: .primary,
            backgroundColor: .cyan,
            isEnabled: false,
            isProminent: true,
            action: {}
        )
        .accessibilityLabel("Tombol simpan tidak aktif")
        CircleIconButton(
            systemName: "checkmark",
            iconColor: .white,
            backgroundColor: .cyan,
            isEnabled: true,
            isProminent: true,
            action: {}
        )
        .accessibilityLabel("Tombol simpan aktif")
    }
}
