//
//  FrekuensiPickerSection.swift
//  A09_C3
//
//  Created by Muhammad Dzakki Abdullah on 15/07/26.
//

import SwiftUI

struct PickerSection: View {
    @Bindable var viewModel: ObatAddViewModel
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    var dynamicLayout: AnyLayout {
        dynamicTypeSize.isAccessibilitySize
        ? AnyLayout(VStackLayout(alignment: .leading, spacing: 4))
        : AnyLayout(HStackLayout(alignment: .center))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            dynamicLayout {
                Text("Frekuensi")
                Spacer()
                FrekuensiChipButton(
                    title: "\(viewModel.jumlahPerHari) kali sehari",
                    isSelected: viewModel.activeChip == .jumlahPerHari && viewModel.isPickerExpanded
                ) {
                    viewModel.selectFrekuensiChip(.jumlahPerHari)
                }
                .accessibilityLabel("Jumlah pemakaian per hari, \(viewModel.jumlahPerHari) kali sehari")
                .accessibilityHint("Ketuk dua kali untuk mengatur jumlah pemakaian per hari")
                .accessibilityAddTraits(.isButton)
                
                FrekuensiChipButton(
                    title: "\(viewModel.jumlahPerKali) \(viewModel.satuanJumlah)",
                    isSelected: viewModel.activeChip == .jumlahPerKali && viewModel.isPickerExpanded
                ) {
                    viewModel.selectFrekuensiChip(.jumlahPerKali)
                }
                .accessibilityLabel("Jumlah per pemakaian, \(viewModel.jumlahPerKali) \(viewModel.satuanJumlah)")
                .accessibilityHint("Ketuk dua kali untuk mengatur jumlah per pemakaian")
                .accessibilityAddTraits(.isButton)
            }

            if viewModel.isPickerExpanded {
                HStack {
                    Picker("", selection: wheelSelection) {
                        ForEach(1...20, id: \.self) { angka in
                            Text("\(angka)").tag(angka)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: dynamicTypeSize >= .accessibility4 &&
                           viewModel.activeChip == .jumlahPerKali &&
                           ["Sendok", "Kapsul"].contains(viewModel.satuanJumlah)
                           ? 135
                           : nil,
                    height: 120)
                    .clipped()
                    .id(viewModel.activeChip)
                    .accessibilityLabel(
                        viewModel.activeChip == .jumlahPerHari
                        ? "Jumlah kali sehari"
                        : "Jumlah \(viewModel.satuanJumlah)"
                    )
                    .accessibilityValue(
                        "\(viewModel.activeChip == .jumlahPerHari ? viewModel.jumlahPerHari : viewModel.jumlahPerKali)"
                    )
                    
                    Text(viewModel.activeChip == .jumlahPerHari ? "kali" : viewModel.satuanJumlah)
                        .font(.body.weight(.semibold))
                        .padding(.trailing, 8)
                        .accessibilityHidden(true)
                }
            }
        }
    }

    private var wheelSelection: Binding<Int> {
        Binding(
            get: {
                viewModel.activeChip == .jumlahPerHari
                    ? viewModel.jumlahPerHari
                    : viewModel.jumlahPerKali
            },
            set: { newValue in
                if viewModel.activeChip == .jumlahPerHari {
                    viewModel.jumlahPerHari = newValue
                } else {
                    viewModel.jumlahPerKali = newValue
                }
            }
        )
    }
}
