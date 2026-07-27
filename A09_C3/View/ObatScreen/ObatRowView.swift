//
//  ObatRowView.swift
//  A09_C3
//
//  Created by Muhammad Dzakki Abdullah on 18/07/26.
//

//
//  ObatRowView.swift
//  A09_C3
//
//  Created by Muhammad Dzakki Abdullah on 18/07/26.
//

import SwiftUI

struct ObatRowView: View {
    
    let obat: Obat
    var keyword: String? = nil
    
    private func highlighted(_ text: String) -> AttributedString {
        var attributed = AttributedString(text)
        guard let keyword, !keyword.isEmpty,
              let range = attributed.range(of: keyword, options: .caseInsensitive) else {
            return attributed
        }
        attributed[range].font = .body.bold()
        attributed[range].backgroundColor = .yellow.opacity(0.4)
        return attributed
    }
    
    private var dosisText: String {
        switch obat.jenis {
        case .tablet, .kapsul: return "\(obat.dosis) mg"
        case .sirup: return "\(obat.dosis) ml"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            
            HStack(alignment: .top) {
                
                VStack(alignment: .leading, spacing: 4) {
                    
                    Text(highlighted(obat.nama))
                        .font(.body)
                    
                    Text(obat.frekuensi)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    if obat.isKondisional,
                       let detail = obat.kondisiDetail,
                       !detail.isEmpty {
                        
                        Text("Kondisi: \(detail)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                VStack (alignment: .trailing, spacing: 4){
                    Text(obat.keterangan.rawValue)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.trailing)
                    Text(dosisText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.trailing)
                }
            }
        }
        //        .padding(.vertical)
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "Obat \(obat.nama). Frekuensi \(obat.frekuensi)."
            + (obat.isKondisional && !(obat.kondisiDetail ?? "").isEmpty ? " Kondisi \(obat.kondisiDetail!)." : "")
            + " \(obat.keterangan.rawValue). Dosis \(dosisText)."
        )
    }
}

#Preview {
    let obat = Obat(
        nama: "Paracetamol",
        jenis: .tablet,
        dosis: "1",
        frekuensi: "3 × sehari 1 tablet",
        keterangan: .sebelumMakan
    )
    
    VStack {
        ObatRowView(obat: obat)
        ObatRowView(obat: obat, keyword: "para")
    }
    .padding()
}
