//
//  PantauanDetailView.swift
//  A09_C3
//
//  Created by Richie Daryl Kwenandar on 19/07/26.
//

import SwiftUI

struct PantauanDetailView: View {
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    
    var dynamicLayout: AnyLayout {
        dynamicTypeSize.isAccessibilitySize ? AnyLayout(VStackLayout(alignment: .leading)) : AnyLayout(HStackLayout(alignment: .top))
    }
    
    let pantauan: PantauanModel
    
    @State private var showEditSheet = false
    
    private var formattedDate: String {
        pantauan.pantauanDate.formatted(
            .dateTime.day().month(.wide).year().locale(Locale(identifier: "id_ID"))
        )
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                dynamicLayout {
                    Text("Tanggal pantauan")
                        .foregroundStyle(.secondary)
                    if !dynamicTypeSize.isAccessibilitySize {
                        Spacer()
                    }
                    Text(formattedDate)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Tanggal pantauan \(formattedDate)")
                
                dynamicLayout {
                    Text(pantauan.pantauanBody)
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 200, alignment: .topLeading)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .accessibilityLabel("Isi pantauannya adalah \(pantauan.pantauanBody)")
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
        .background(Color("backgroundColor"))
        .navigationTitle("Detail Pantauan")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    showEditSheet = true
                }
                .foregroundStyle(.primary)
                .accessibilityLabel("Edit Pantauan")
            }
        }
        .fullScreenCover(isPresented: $showEditSheet) {
            AddPantauan(pantauanToEdit: pantauan)
                .interactiveDismissDisabled()
        }
    }
}

#Preview {
    NavigationStack {
        PantauanDetailView(
            pantauan: PantauanModel(pantauanDate: .now, pantauanBody: "Sakit tenggorokan batuk batuk")
        )
    }
}
