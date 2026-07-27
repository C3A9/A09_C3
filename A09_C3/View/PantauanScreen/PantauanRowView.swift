//
//  PantauanRowView.swift
//  A09_C3
//
//  Created by Richie Daryl Kwenandar on 19/07/26.
//

import SwiftUI

struct PantauanRowView: View {
    let pantauan: PantauanModel
    
    private var formattedDate: String {
        pantauan.pantauanDate.formatted(
            .dateTime
                .day()
                .month(.wide)
                .year()
                .locale(Locale(identifier: "id_ID"))
        )
    }
    
    var body: some View {
            NavigationLink {
                PantauanDetailView(pantauan: pantauan)
            } label: {
                HStack {
                    Text(formattedDate)
                    .font(.body)
                    Spacer()
                }
                .frame(minHeight: 30)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(
                Text("Pantauan tanggal \(formattedDate)")
            )
            .accessibilityHint("Ketuk dua kali untuk melihat detail pantauan")
            .accessibilityAddTraits(.isButton)
            .spokenIn("id_ID")
        }
    }

#Preview {
    ZStack {
        Color("backgroundColor")
            .ignoresSafeArea()
        PantauanRowView(pantauan: PantauanModel(pantauanDate: .now, pantauanBody: "Sakit tenggorokan, batuk-batuk"))
            .padding(.horizontal, 20)
    }
}

