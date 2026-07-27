//
//  SearchResultRowView.swift
//  A09_C3
//
//  Created by Richie Daryl Kwenandar on 21/07/26.
//

import SwiftUI

struct SearchResultRowView: View {
    let item: SearchResultItem
    let keyword: String
    
    private func highlighted(_ text: String) -> AttributedString {
        var attributed = AttributedString(text)
        guard let range = attributed.range(of: keyword, options: .caseInsensitive) else {
            return attributed
        }
        attributed[range].font = .body.bold()
        attributed[range].backgroundColor = .yellow.opacity(0.4)
        return attributed
    }
    
    var body: some View {
        
        if case let .obat(obat) = item.destination {
            
            ObatRowView(obat: obat, keyword: keyword)
            
        } else {
            
            HStack {
                
                VStack(alignment: .leading, spacing: 4) {
                    
                    Text(highlighted(item.primaryText))
                        .font(.body)
                        .foregroundStyle(.primary)
                    
                    Text(highlighted(item.secondaryText))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.tertiary)
                
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(item.primaryText). \(item.secondaryText)")
            .accessibilityHint("Ketuk dua kali untuk melihat detail")
            .accessibilityAddTraits(.isButton)
        }
    }
}
    
    #Preview {
        List {
            SearchResultRowView(
                item: SearchResultItem(
                    category: .obat,
                    primaryText: "Tolak Angin",
                    secondaryText: "3x sehari 1 tablet",
                    contextText: "Sebelum makan · 500 mg",
                    destination: .obat(Obat(nama: "Tolak Angin", jenis: .tablet, dosis: "500", frekuensi: "3x sehari 1 tablet", keterangan: .sebelumMakan))
                ),
                keyword: "Tolak"
            )
            
            SearchResultRowView(
                item: SearchResultItem(
                    category: .pantauan,
                    primaryText: "20 Juli 2026",
                    secondaryText: "Batuk pilek",
                    contextText: nil,
                    destination: .pantauan(PantauanModel(pantauanDate: .now, pantauanBody: "Batuk pilek"))
                ),
                keyword: "Batuk"
            )
        }
    }
