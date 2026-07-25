//
//  AddKonsul.swift
//  A09_C3
//
//  Created by Dina on 17/07/26.
//

import SwiftUI
import SwiftData

struct AddKonsul: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    var konsultasiToEdit: KonsulModel?
    
    @State private var namaDokter: String = ""
    @State private var tanggalKonsultasi: Date = .now
    @State private var content: String = ""
    @State private var dictationManager = DictationManager()
    @State private var errorMessage: String?
    @State private var showCancelAlert = false
    @State private var errorMessageName: String?
    
    @FocusState private var isTextFieldFocused: Bool
    
    private var modalTitle: String {
        konsultasiToEdit == nil ? "Konsultasi Baru" : "Edit Konsultasi"
    }
    
    private func isValidDokterName(_ name: String) -> Bool {
        let allowedCharacters = CharacterSet.letters
            .union(.whitespaces)
            .union(CharacterSet(charactersIn: ".,"))
        return name.unicodeScalars.allSatisfy { allowedCharacters.contains($0) }
    }
    
    private var cancelAlertTitle: String {
        konsultasiToEdit == nil ? "Batalkan penambahan konsultasi?" : "Batalkan perubahan?"
    }
    
    private var cancelAlertMessage: String {
        konsultasiToEdit == nil
        ? "Jika Anda keluar sekarang, informasi konsultasi yang telah diisi tidak akan disimpan."
        : "Jika Anda kembali sekarang, semua perubahan yang telah dibuat akan hilang."
    }
    
    private var hasUnsavedChanges: Bool {
        guard let konsultasiToEdit else {
            return !namaDokter.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        return namaDokter != konsultasiToEdit.namaDokter || tanggalKonsultasi != konsultasiToEdit.tanggalKonsultasi || content != konsultasiToEdit.content
    }
    
    private var isSaveEnabled: Bool {
        guard konsultasiToEdit != nil else {
            return !namaDokter.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        return hasUnsavedChanges
    }
    
    var body: some View {
        AddModal(
            title: modalTitle,
            isSaveEnabled: isSaveEnabled,
            onClose: { handleClose() },
            onSave: {
                save() }
        ) {
            Section {
                
                TextField(text: $namaDokter, prompt: Text("Nama Dokter")) {
                    Text("Nama")
                        .accessibilityLabel("Tuliskan nama dokter")
                }
                .focused($isTextFieldFocused)
                
                if let errorMessageName {
                    Text(errorMessageName)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .accessibilityLabel(errorMessageName)
                }
                ExpandableDatePicker(label: "Tanggal konsultasi", selection: $tanggalKonsultasi)
                    .accessibilityLabel("Tanggal konsultasi")
                
            }
            
            Section {
                ScrollView{
                    ZStack(alignment: .bottomTrailing) {
                        TextField(
                            "Content",
                            text: $content,
                            prompt: Text("Ketik atau ketuk ikon mikrofon untuk berbicara"),
                            axis: .vertical
                        )
                        .accessibilityLabel("Ketik disini untuk menulis konsultasi atau ketuk mikrofon")
                        .autocorrectionDisabled()
                        .lineLimit(8...100)
                        .padding(.trailing, 44)
                        .focused($isTextFieldFocused)
                        
                        DictationButton(
                            dictationManager: dictationManager,
                            text: $content,
                            onError: { message in errorMessage = message }
                        )
                        .padding(8)
                        .accessibilityLabel("Ketuk mikrofon dan mulai berbicara")
                        .simultaneousGesture(
                            TapGesture().onEnded {
                                isTextFieldFocused = false
                            }
                        )
                    }
                }
                
                
                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .accessibilityLabel(errorMessage)
                }
            }
        }
        .onAppear(perform: loadExistingData)
        .alert(cancelAlertTitle, isPresented: $showCancelAlert) {
            Group {
                Button("Batalkan", role: .destructive) {
                    dismiss()
                }
                .accessibilityLabel("Batalkan penambahan obat")
                .accessibilityHint("Keluar tanpa menyimpan perubahan")
                Button("Lanjutkan Mengedit", role: .cancel) {}
                    .accessibilityLabel("Lanjutkan mengedit")
                    .accessibilityHint("Kembali pada halaman tanpa menghapus data")
            }
            .tint(.black)
        } message: {
            Text(cancelAlertMessage)
        }
    }
    
    private func loadExistingData() {
        guard let konsultasiToEdit else { return }
        namaDokter = konsultasiToEdit.namaDokter
        tanggalKonsultasi = konsultasiToEdit.tanggalKonsultasi
        content = konsultasiToEdit.content
    }
    
    private func handleClose() {
        if hasUnsavedChanges {
            showCancelAlert = true
        } else {
            dismiss()
        }
    }
    
    
    private func save() {
        let viewModel = KonsultasiViewModel(modelContext: modelContext)
        
        do {
            if let konsultasiToEdit {
                try viewModel.update(
                    konsultasiToEdit,
                    namaDokter: namaDokter,
                    tanggal: tanggalKonsultasi,
                    content: content)
            } else {
                try viewModel.addKonsultasi(
                    namaDokter: namaDokter,
                    tanggal: tanggalKonsultasi,
                    content: content)
            }
            dismiss()
        } catch KonsultasiValidationError.emptyDokter {
            errorMessage = "Nama dokter tidak boleh kosong"
        } catch KonsultasiValidationError.emptyBody {
            errorMessage = "Catatan tidak boleh kosong"
        } catch KonsultasiValidationError.namaDokterSimbol {
            errorMessageName = "Nama dokter tidak boleh mengandung angka atau simbol (selain titik)"
        }catch {
            errorMessage = "Terjadi kesalahan, coba lagi"
        }
    }
    
}


#Preview {
    AddKonsul()
        .modelContainer(for: KonsulModel.self, inMemory: true)
}

