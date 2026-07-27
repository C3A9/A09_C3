//
//  RingkasanView.swift
//  A09_C3
//
//  Created by Richie Daryl Kwenandar on 17/07/26.
//

import SwiftUI
import SwiftData

struct RingkasanView: View {
    @Environment(TranslationBridge.self) private var translationBridge
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    @State private var viewModel: RingkasanViewModel?

    @Query(sort: \PantauanModel.pantauanDate, order: .reverse)
    private var pantauanList: [PantauanModel]

    @Query(sort: \KonsulModel.tanggalKonsultasi, order: .reverse)
    private var konsulList: [KonsulModel]

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
                    }
                    Spacer()
                }

                if isDataKosong {
                    EmptyStateView(message: "Tambahkan Pantauan atau Konsultasi untuk melihat Ringkasan")
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
                                }
                                .refreshable {
                                    await viewModel.generateSemuaRingkasan(
                                        pantauanList: pantauanList,
                                        konsulList: konsulList
                                    )
                                }
                            } else {
                                ProgressView()
                            }
                        }
                    }
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
        }
    }
}
