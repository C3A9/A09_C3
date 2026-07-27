//
//  RingkasanView.swift
//  A09_C3
//
//  Created by Richie Daryl Kwenandar on 17/07/26.
//

import SwiftUI
import SwiftData
import CloudKit

struct RingkasanView: View {
    @Environment(TranslationBridge.self) private var translationBridge
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    @State private var viewModel: RingkasanViewModel?
    
    @Query(sort: \PantauanModel.pantauanDate, order: .reverse)
    private var pantauanList: [PantauanModel]
    
    @Query(sort: \KonsulModel.tanggalKonsultasi, order: .reverse)
    private var konsulList: [KonsulModel]
    
    @Query private var careGroups: [CareGroupModel]
    
    @State private var activeShare: CKShare?
    @State private var shareContainer: CKContainer?
    @State private var isPresentingShareSheet = false
    @State private var isPreparingShare = false
    @State private var shareErrorMessage: String?
    @State private var syncErrorMessage: String?
    @State private var hasSyncedOnce = false
    
    private var isDataKosong: Bool {
        pantauanList.isEmpty && konsulList.isEmpty
    }
    
    var dynamicLayout: AnyLayout {
        dynamicTypeSize.isAccessibilitySize
        ? AnyLayout(VStackLayout(alignment: .leading))
        : AnyLayout(HStackLayout(alignment: .center))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color("backgroundColor")
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    ScreenHeader(title: "Ringkasan", icon: "square.and.arrow.up") {
                        Task { await handleShareTapped() }
                    }
                    Spacer()
                }
                
                if isDataKosong {
                    ScrollView {
                        EmptyStateView(message: "Tambahkan Pantauan atau Konsultasi untuk melihat Ringkasan")
                            .frame(maxWidth: .infinity, minHeight: 400)
                    }
                    .refreshable {
                        await syncThenGenerateRingkasan()
                    }
                } else {
                    VStack(spacing: 0) {
                        Spacer().frame(height: 100)
                        
                        Group {
                            if let viewModel {
                                ScrollView {
                                    VStack(spacing: 16) {
                                        if !viewModel.isModelAvailable {
                                            dynamicLayout {
                                                Text("Apple Intelligence belum aktif di perangkat ini. Aktifkan melalui Settings untuk memakai fitur ringkasan.")
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                                    .padding()
                                            }
                                            .accessibilityElement(children: .combine)
                                        }
                                        
                                        if !pantauanList.isEmpty {
                                            RingkasanSectionView(
                                                title: "Pantauan",
                                                lastUpdated: viewModel.lastUpdatedPantauan,
                                                poinPenting: viewModel.poinPantauan,
                                                isGenerating: viewModel.isGeneratingPantauan,
                                                error: viewModel.errorPantauan
                                            )
                                        }
                                        
                                        if !konsulList.isEmpty {
                                            RingkasanSectionView(
                                                title: "Konsultasi",
                                                lastUpdated: viewModel.lastUpdatedKonsultasi,
                                                poinPenting: viewModel.poinKonsultasi,
                                                isGenerating: viewModel.isGeneratingKonsultasi,
                                                error: viewModel.errorKonsultasi
                                            )
                                        }
                                        
                                        Text("Informasi yang dirangkum AI dapat mengandung kesalahan atau ketidakakuratan. Selalu periksa kembali informasi penting dan ikuti arahan tenaga kesehatan.")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    .padding(.horizontal, 20)
                                    .spokenIn("id_ID")
                                }
                                .refreshable {
                                    await viewModel.generateSemuaRingkasan(
                                        pantauanList: pantauanList,
                                        konsulList: konsulList
                                    )
                                    await syncThenGenerateRingkasan()
                                }
                            } else {
                                ProgressView()
                            }
                        }
                    }
                }
                
                if isPreparingShare {
                    ProgressView("Menyiapkan tautan berbagi...")
                        .padding()
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            if viewModel == nil {
                let service = RingkasanService(translationBridge: translationBridge)
                let newViewModel = RingkasanViewModel(service: service)
                viewModel = newViewModel
                newViewModel.loadCachedDisplay(pantauanList: pantauanList, konsulList: konsulList)
            }
            if !hasSyncedOnce {
                hasSyncedOnce = true
                Task { await syncOnly() }
            }
        }
        .sheet(isPresented: $isPresentingShareSheet) {
            if let activeShare, let shareContainer {
                CloudSharingView(share: activeShare, container: shareContainer)
            }
        }
        .alert(
            "Gagal membuat tautan berbagi",
            isPresented: Binding(
                get: { shareErrorMessage != nil },
                set: { if !$0 { shareErrorMessage = nil } }
            )
        ) {
            Button("OK") { shareErrorMessage = nil }
        } message: {
            Text(shareErrorMessage ?? "")
        }
        .alert(
            "Gagal sinkronisasi data",
            isPresented: Binding(
                get: { syncErrorMessage != nil },
                set: { if !$0 { syncErrorMessage = nil } }
            )
        ) {
            Button("OK") { syncErrorMessage = nil }
        } message: {
            Text(syncErrorMessage ?? "")
        }
    }
    
    @MainActor
    private func handleShareTapped() async {
        guard !isPreparingShare else { return }
        isPreparingShare = true
        defer { isPreparingShare = false }
        
        do {
            let careGroup: CareGroupModel
            if let existing = careGroups.first(where: { $0.isOwner }) {
                careGroup = existing
            } else {
                careGroup = try await SharingManager.shared.createCareGroup(
                    patientName: "Pasien Saya",
                    context: modelContext
                )
                await ShareSyncService.shared.migrateExistingRecords(
                    to: careGroup,
                    context: modelContext
                )
            }
            
            let (share, container) = try await SharingManager.shared.createShare(for: careGroup)
            activeShare = share
            shareContainer = container
            isPresentingShareSheet = true
        } catch {
            shareErrorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    private func syncOnly() async {
        guard let careGroup = careGroups.first else { return }
        do {
            try await ShareSyncService.shared.refreshSharedData(careGroup: careGroup, context: modelContext)
        } catch {
            print("Auto-sync awal gagal: \(error)")
        }
    }
    
    @MainActor
    private func syncThenGenerateRingkasan() async {
        if let careGroup = careGroups.first {
            do {
                if careGroup.isOwner {
                    await ShareSyncService.shared.pushUnsyncedRecords(for: careGroup, context: modelContext)
                }
                try await ShareSyncService.shared.refreshSharedData(careGroup: careGroup, context: modelContext)
            } catch {
                syncErrorMessage = error.localizedDescription
            }
        }
        
        if let viewModel {
            await viewModel.generateSemuaRingkasan(pantauanList: pantauanList, konsulList: konsulList)
        }
    }
}
