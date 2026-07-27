import SwiftUI
import SwiftData
import TipKit

struct KonsulListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \KonsulModel.tanggalKonsultasi, order: .reverse)
    private var allKonsul: [KonsulModel]
    
    @State private var konsultasiToDelete: KonsulModel?
    @State private var showAddSheet = false
    @State private var showDeleteAlert = false
    
    @AppStorage("hasShownSwipeDeleteTip") private var hasShownSwipeDeleteTip = false
    private let swipeToDeleteTip = SwipeToDeleteTip()
    
    private var konsulViewModel: KonsultasiViewModel {
        KonsultasiViewModel(modelContext: modelContext)
    }
    
    private var firstKonsulID: PersistentIdentifier? {
            allKonsul.first?.id
        }
    
    //grup berdasarkan bulan
    private var groupedKonsul: [(key: String, items: [KonsulModel])] {
        let grouped = Dictionary(grouping: allKonsul) { konsul in
            konsul.tanggalKonsultasi.formatted(.dateTime.month(.wide).year()
                .locale(Locale(identifier: "id_ID")))
            
        }
        //berdasarkan tanggal paling baru
        return grouped.sorted { lhs, rhs in
            guard let lhsDate = lhs.value.first?.tanggalKonsultasi,
                  let rhsDate = rhs.value.first?.tanggalKonsultasi else {
                return false
            }
            return lhsDate > rhsDate
        }.map { (key: $0.key, items: $0.value) }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("backgroundColor")
                    .ignoresSafeArea()
                
                // Layer 1: Header, selalu nempel di atas
                VStack(spacing: 16) {
                    ScreenHeader(title: "Konsultasi") {
                        showAddSheet = true
                    }
                    Spacer()
                }
                
                if allKonsul.isEmpty {
                    EmptyStateView(message: "Ketuk tombol tambah untuk mencatat konsultasi")
                } else {
                    VStack(spacing: 0) {
                        Spacer().frame(height: 50)
                        List {
                            ForEach(groupedKonsul, id: \.key) { group in
                                Section {
                                    ForEach(group.items) { konsul in
                                        KonsulRowView(konsul: konsul)
                                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                                Button {
                                                    konsultasiToDelete = konsul
                                                    showDeleteAlert = true
                                                    swipeToDeleteTip.invalidate(reason: .actionPerformed)
                                                } label: {
                                                    Label("Hapus", systemImage: "trash")
                                                }
                                                .tint(.red)
                                                .accessibilityLabel("Hapus konsultasi dengan \(konsul.namaDokter)")
                                                
                                            }
                                            .popoverTip(konsul.id == firstKonsulID ? swipeToDeleteTip : nil)
                                    }
                                } header: {
                                    Text(group.key)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.secondary)
                                        .accessibilityLabel("Catatan Bulan \(group.key)")
                                        
                                }
                            }
                        }
                        .listStyle(.insetGrouped)
                        .scrollContentBackground(.hidden)
                    }
                }
            }
        }
        .onChange(of: allKonsul.count) { oldValue, newValue in
            if oldValue == 0 && newValue == 1 && !hasShownSwipeDeleteTip {
            SwipeToDeleteTip.shouldShow = true
            hasShownSwipeDeleteTip = true
                Task {
                    try? await Task.sleep(for: .seconds(8))
                    swipeToDeleteTip.invalidate(reason: .tipClosed)
                    }
                }
            }
        
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showAddSheet) {
            AddKonsul()
                .interactiveDismissDisabled()
        }
        .alert("Hapus Konsultasi?", isPresented: $showDeleteAlert, presenting: konsultasiToDelete) { konsultasi in
            Button("Tidak", role: .cancel) {}
                .tint(.black)
            Button("Hapus", role: .destructive) {
                konsulViewModel.delete(konsultasi)
            }
        } message: { _ in
            Text("Apakah Anda yakin ingin menghapus konsultasi ini?")
        }
    }
}

#Preview {
    KonsulListView()
        .modelContainer(for: KonsulModel.self, inMemory: true)
}
