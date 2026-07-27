//
//  ScreenHeader.swift
//  A09_C3
//
//  Created by Richie Daryl Kwenandar on 17/07/26.
//

import SwiftUI

struct ScreenHeader: View {
    var title: String
    var icon: String = "plus"
    let addAction: () -> Void

    private var actionAccessibilityLabel: String {
        switch icon {
        case "square.and.arrow.up":
            return "Bagikan \(title)"
        default:
            return "Tambah \(title)"
        }
    }

    private var actionAccessibilityHint: String {
        switch icon {
        case "square.and.arrow.up":
            return "Ketuk dua kali untuk membagikan \(title.lowercased())"
        default:
            return "Ketuk dua kali untuk menambahkan item baru"
        }
    }

    var body: some View {
        HStack {
            Text(title)
                .accessibilityAddTraits(.isHeader)
                .font(.largeTitle)
                .fontWeight(.bold)
                .accessibilityLabel("Judul \(title)")

            Spacer()

            CircleIconButton(
                systemName: icon,
                iconColor: .white,
                backgroundColor: .cyan,
                size: 48,
                iconSize: 22,
                isProminent: true,
                action: addAction
            )
            .accessibilityLabel(actionAccessibilityLabel)
            .accessibilityHint(actionAccessibilityHint)
        }
        .padding(.horizontal, 20)
        .spokenIn("id_ID")
    }
}

#Preview {
    ZStack {
        Color("backgroundColor")
            .ignoresSafeArea()
        VStack {
            ScreenHeader(title: "Obat") {}
            ScreenHeader(title: "Ringkasan", icon: "square.and.arrow.up") {}
            Spacer()
        }
    }
}
