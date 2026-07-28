//
//  ObatAddViewModel.swift
//  A09_C3
//
//  Created by Muhammad Dzakki Abdullah on 15/07/26.
//

import SwiftUI
import SwiftData
import Observation
import WidgetKit

// MARK: - Frekuensi chip yang sedang aktif (menentukan wheel picker mana yang tampil)
enum FrekuensiChip: Equatable {
    case jumlahPerHari   // "3 kali sehari"
    case jumlahPerKali   // "1 Tablet" / "1 Kapsul" / "1 ml"
}

@Observable
final class ObatAddViewModel {

    // MARK: - Form State (AC: User can input Obat details manually)
    var nama: String = ""
    var jenis: JenisObat = .tablet
    var dosis: String = ""
    var keterangan: KeteranganObat = .sebelumMakan
    var isKondisional: Bool = false
    var kondisiDetail: String = ""

    // Frekuensi sekarang berupa 2 chip + wheel picker angka
    var jumlahPerHari: Int = 1       // "kali sehari"
    var jumlahPerKali: Int = 1       // sesuai satuan Jenis
    var activeChip: FrekuensiChip = .jumlahPerHari

    // Wheel picker baru muncul setelah salah satu chip Frekuensi di-tap.
    // Default false supaya saat halaman pertama dibuka, picker belum tampil.
    var isPickerExpanded: Bool = false

    var showCancelAlert = false
    var attemptedSave = false

    var jenisJadwal: ObatTab {
        get { isKondisional ? .kondisional : .rutin }
        set { isKondisional = (newValue == .kondisional) }
    }
    
    // Satuan untuk chip kedua, menyesuaikan Jenis obat yang dipilih
    var satuanJumlah: String {
        switch jenis {
        case .tablet: return "Tablet"
        case .kapsul: return "Kapsul"
        case .sirup: return "Sendok"
        }
    }
    
    // Satuan dosis, menyesuaikan Jenis obat yang dipilih
    var satuanDosis: String {
        switch jenis {
        case .tablet, .kapsul: return "mg"
        case .sirup: return "ml"
        }
    }

    // Gabungan nilai Frekuensi yang akan disimpan ke model (field `frekuensi: String`)
    var frekuensiText: String {
        "\(jumlahPerHari) kali sehari, \(jumlahPerKali) \(satuanJumlah)"
    }
    
    private static let allowedNameCharacters: CharacterSet = {
            var allowed = CharacterSet.letters
            allowed.formUnion(.decimalDigits)
            allowed.formUnion(.whitespaces)
            allowed.insert(charactersIn: "-/")
            return allowed
        }()
    

    // MARK: - Validation
    // AC: User can save the Obat note only when all required information has been provided
    
    var isValidMedicineName: Bool {
            nama.unicodeScalars.allSatisfy { Self.allowedNameCharacters.contains($0) }
        }
    
    
    var isFormValid: Bool {
        let trimmedDosis = dosis.trimmingCharacters(in: .whitespaces)

        let baseValid = !nama.trimmingCharacters(in: .whitespaces).isEmpty
            && isValidMedicineName
            && !trimmedDosis.isEmpty
            && (Int(trimmedDosis) ?? 0) > 0
            && jumlahPerHari > 0
            && jumlahPerKali > 0

        if isKondisional {
            return baseValid && !kondisiDetail.trimmingCharacters(in: .whitespaces).isEmpty
        }

        return baseValid
    }

    // Cek apakah user sudah mengisi sesuatu, untuk menentukan perlu konfirmasi batal atau tidak
    var hasUnsavedChanges: Bool {
        !nama.isEmpty
            || !dosis.isEmpty
            || isKondisional
            || !kondisiDetail.isEmpty
    }

    // MARK: - Actions
    

    // AC: User can only input numeric value for Dosis, angka "0" dianggap kosong
    func updateDosis(_ newValue: String) {
        let filtered = newValue.filter(\.isNumber)
        if let value = Int(filtered), value == 0 {
            dosis = ""
        } else {
            dosis = filtered
        }
    }

    //Frekuensi Picker Actions
    func selectFrekuensiChip(_ chip: FrekuensiChip) {
        if activeChip == chip && isPickerExpanded {
            // Chip yang sama di-tap lagi saat picker sedang terbuka -> tutup
            isPickerExpanded = false
        } else {
            // Chip berbeda, atau picker belum terbuka -> buka & pindah ke chip ini
            activeChip = chip
            isPickerExpanded = true
        }
    }
    /// AC: User can cancel note creation without saving any changes
    func handleClose(dismiss: () -> Void) {
        if hasUnsavedChanges {
            showCancelAlert = true
        } else {
            dismiss()
        }
    }

    func save(modelContext: ModelContext, dismiss: () -> Void) {
        attemptedSave = true
        guard isFormValid else { return }

        let newObat = Obat(
            nama: nama.trimmingCharacters(in: .whitespaces),
            jenis: jenis,
            dosis: dosis.trimmingCharacters(in: .whitespaces),
            frekuensi: frekuensiText,
            keterangan: keterangan,
            isKondisional: isKondisional,
            kondisiDetail: isKondisional ? kondisiDetail.trimmingCharacters(in: .whitespaces) : nil
        )
        modelContext.insert(newObat)
//        WidgetCenter.shared.reloadTimelines(ofKind: "ObatWidget")
        dismiss()
    }
}
