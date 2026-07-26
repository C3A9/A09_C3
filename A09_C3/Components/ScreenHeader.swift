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
            .accessibilityLabel("Tambah \(title)")
            .accessibilityHint("Ketuk dua kali untuk menambahkan item baru")
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    ZStack {
        Color("backgroundColor")
            .ignoresSafeArea()
        VStack {
            ScreenHeader(title: "Obat") {}
            Spacer()
        }
    }
}
