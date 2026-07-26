//
//  AddModal.swift
//  A09_C3
//
//  Created by Dina on 17/07/26.
//

import SwiftUI

struct AddModal<Content: View>: View {
    let title: String
    var isSaveEnabled: Bool = true
    let onClose: () -> Void
    let onSave: () -> Void
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 1) {
            // Header
            HStack {
                CircleIconButton(
                    systemName: "xmark",
                    iconColor: .primary,
                    backgroundColor: Color("buttonCross").opacity(0.16),
                    action: onClose
                )
                .accessibilityLabel("Tutup \(title)")

                Spacer()

                Text(title)
                    .font(.system(size: 20, weight: .semibold))
                    .accessibilityLabel(title)

                Spacer()

                CircleIconButton(
                    systemName: "checkmark",
                    iconColor: .white,
                    backgroundColor: .cyan,
                    isEnabled: isSaveEnabled,
                    isProminent: true,
                    action: onSave
                )
                .accessibilityLabel("Simpan \(title)")
                .accessibilityHint(
                    isSaveEnabled
                    ? "Ketuk dua kali untuk menyimpan."
                    : "Tombol masih tidak aktif. Apabila ingin mengaktifkan, silakan mengisi semua isian terlebih dahulu")
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)

            Form {
                content
            }
            .scrollContentBackground(.hidden)

            Spacer()
        }
        .background(Color("backgroundColor"))
    }
}

#Preview {
    AddModal(
        title: "Konsultasi Baru",
        isSaveEnabled: false,
        onClose: {},
        onSave: {}
    ) {
        Section {
            
        }
    }
}
