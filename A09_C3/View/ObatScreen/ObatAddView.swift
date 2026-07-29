//
//  ObatAddView.swift
//  A09_C3
//
//  Created by Muhammad Dzakki Abdullah on 15/07/26.
//

import SwiftUI
import SwiftData

struct ObatAddView: View {

    @FocusState private var isTextFieldFocused: Bool
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    
    var dynamicLayout: AnyLayout {
        dynamicTypeSize.isAccessibilitySize
        ? AnyLayout(VStackLayout(alignment: .leading))
        : AnyLayout(HStackLayout(alignment: .top))
    }
    
    var dynamicLayoutJenis: AnyLayout {
        dynamicTypeSize >= .accessibility4
            ? AnyLayout(VStackLayout(alignment: .leading))
            : AnyLayout(HStackLayout(alignment: .center))
    }

    @State private var viewModel = ObatAddViewModel()
    @State private var selectedTab: ObatTab = .rutin

    var body: some View {
        AddModal(
            title: "Obat Baru",
            isSaveEnabled: viewModel.isFormValid,
            onClose: {
                viewModel.handleClose(dismiss: { dismiss() })
            },
            onSave: {
                viewModel.save(modelContext: modelContext, dismiss: { dismiss() })
            }
        ) {
            Section {
                TextField("Tambahkan Nama Obat", text: $viewModel.nama)
                    .focused($isTextFieldFocused)
                if !viewModel.isValidMedicineName {
                    Text("Nama obat tidak boleh mengandung simbol atau karakter khusus")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
                
                dynamicLayoutJenis {
                    Text("Jenis")
                    Spacer()
                    Picker("", selection: $viewModel.jenis) {
                        ForEach(JenisObat.allCases) { jenis in
                            Text(jenis.rawValue).tag(jenis)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(.secondary)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text("Jenis obat"))
                .accessibilityValue(Text(viewModel.jenis.rawValue))
                .accessibilityHint("Ketuk dua kali untuk memilih jenis obat")
                
                PickerSection(viewModel: viewModel)
                
                HStack {
                    Text("Dosis")
                    HStack(spacing: 4) {
                        TextField("100", text: $viewModel.dosis)
                            .keyboardType(.numberPad)
                            .onChange(of: viewModel.dosis) { _, newValue in
                                viewModel.updateDosis(newValue)
                            }
                            .multilineTextAlignment(.trailing)
                            .foregroundStyle(viewModel.dosis.isEmpty ? .secondary : .primary)
                            .focused($isTextFieldFocused)
                        
                        Text(viewModel.satuanDosis)
                            .foregroundStyle(.secondary)
                            .accessibilityHidden(true)
                    }
                }
                
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Dosis")
                .accessibilityValue(
                    viewModel.dosis.isEmpty
                    ? "Belum diisi"
                    : "\(viewModel.dosis) \(viewModel.satuanDosis)"
                )
                .accessibilityHint("Ketuk dua kali untuk mengubah dosis")
                
                if viewModel.attemptedSave && viewModel.dosis.trimmingCharacters(in: .whitespaces).isEmpty {
                    Text("Dosis wajib diisi")
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                Picker("Keterangan", selection: $viewModel.keterangan) {
                    ForEach(KeteranganObat.allCases) { keterangan in
                        Text(keterangan.rawValue).tag(keterangan)
                    }
                }
                .pickerStyle(.menu)
                .tint(.secondary)
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("Waktu Minum")
                    
                    Picker("Jenis Jadwal", selection: $viewModel.jenisJadwal) {
                        ForEach(ObatTab.allCases) { jenis in
                            Text(jenis.rawValue)
                                .tag(jenis)
                        }
                        .tint(.secondary)
                    }
                    .pickerStyle(.segmented)
                    .accessibilityLabel("Jenis jadwal minum obat")

                }

                // AC: If Kondisional dipilih, user bisa isi detail kondisi
                if viewModel.isKondisional {
                    TextField("Detail kondisi (cth: saat demam)", text: $viewModel.kondisiDetail)
                        .accessibilityLabel("Detail kondisi obat kondisional. Contoh: saat demam")
                        .focused($isTextFieldFocused)
                    if viewModel.attemptedSave && viewModel.kondisiDetail.trimmingCharacters(in: .whitespaces).isEmpty {
                        Text("Detail kondisi wajib diisi")
                            .font(.caption)
                            .foregroundStyle(.red)
                            .accessibilityLabel("Detail kondisi wajib diisi")
                    }
                }
            }
        }
        .simultaneousGesture(
            TapGesture().onEnded {
                isTextFieldFocused = false
            }
        )
        .scrollDismissesKeyboard(.immediately)
        .alert("Batalkan penambahan obat?", isPresented: $viewModel.showCancelAlert) {
            Button("Batalkan", role: .destructive) {
                dismiss()
            }
            .accessibilityLabel("Batalkan penambahan obat")
            .accessibilityHint("Keluar tanpa menyimpan perubahan")
            Button("Lanjutkan Mengedit", role: .cancel) {}
                .tint(.black)
                .accessibilityLabel("Lanjutkan mengedit")
                .accessibilityHint("Kembali pada halaman tanpa menghapus data")
        } message: {
            Text("Jika Anda keluar sekarang, informasi obat yang telah diisi tidak akan disimpan.")
        }
        .interactiveDismissDisabled(viewModel.hasUnsavedChanges)
        .spokenIn("id_ID")
    }
}

#Preview {
    ObatAddView()
        .modelContainer(for: Obat.self, inMemory: true)
}
