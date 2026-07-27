//
//  KonsulRowView.swift
//  A09_C3
//
//  Created by Dina on 19/07/26.
//

import SwiftUI

struct KonsulRowView: View {
    let konsul: KonsulModel
    
    private var formattedDate: String {
        konsul.tanggalKonsultasi.formatted(
            .dateTime.day().month(.wide).year()
            .locale(Locale(identifier: "id_ID"))
        )
    }
    
    var body: some View {
        NavigationLink {
            KonsulDetailView(konsultasi: konsul)
        } label: {
            VStack(alignment: .leading) {
                Text(konsul.namaDokter)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(konsul.tanggalKonsultasi.formatted(.dateTime.day().month(.wide).year().locale(Locale(identifier: "id_ID"))))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(1)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            Text("Konsultasi dengan \(konsul.namaDokter), tanggal \(formattedDate)")
        )
        .accessibilityHint("Ketuk dua kali untuk melihat detail konsultasi")
        .accessibilityAddTraits(.isButton)
        .spokenIn("id_ID")
    }
}

#Preview {
    List {
        KonsulRowView(konsul: KonsulModel(
            namaDokter: "dr. Lala",
            tanggalKonsultasi: .now,
            content: "Kontrol rutin"
        ))
        KonsulRowView(konsul: KonsulModel(
            namaDokter: "dr. Lili",
            tanggalKonsultasi: .now,
            content: "Kontrol rutin"
        ))
    }
}

