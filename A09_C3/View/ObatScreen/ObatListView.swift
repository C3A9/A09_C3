import SwiftUI
import SwiftData
import TipKit
import WidgetKit

struct ObatListView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Query(sort: \Obat.createdAt, order: .reverse)
    private var allObat: [Obat]

    @State private var selectedTab: ObatTab = .rutin
    @State private var showAddSheet = false
    @State private var showDeleteAlert = false
    @State private var obatToDelete: Obat?

    @AppStorage("hasShownSwipeDeleteTip") private var hasShownSwipeDeleteTip = false
    private let swipeToDeleteTip = SwipeToDeleteTip()

    private var filteredObat: [Obat] {
        switch selectedTab {
        case .rutin:
            return allObat.filter { !$0.isKondisional }

        case .kondisional:
            return allObat.filter { $0.isKondisional }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color("backgroundColor")
                    .ignoresSafeArea()

                VStack{

                    ScreenHeader(title: "Obat") {
                        showAddSheet = true
                    }


                    Picker("Filter Obat", selection: $selectedTab) {
                        ForEach(ObatTab.allCases) { tab in
                            Text(tab.rawValue)
                                .tag(tab)
                        }
                    }
                    .pickerStyle(.segmented)
                    .animation(
                        reduceMotion ? nil : .default,
                        value: selectedTab
                    )
                    .padding(.horizontal)
                    .accessibilityLabel("Filter obat")
                    .accessibilityValue(selectedTab.rawValue)
                    .accessibilityHint("Pilih untuk menampilkan obat rutin atau kondisional")
                    Spacer()

                    if filteredObat.isEmpty {
                        EmptyStateView(message: "Ketuk tombol tambah untuk menambah obat")
                        Spacer()
                            .frame(height: 263)
                    }
                    else {
                        List {
                            Section {
                                ForEach(Array(filteredObat.enumerated()), id: \.element.id) { index, obat in
                                    ObatRowView(obat: obat)
                                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                            Button {
                                                obatToDelete = obat
                                                showDeleteAlert = true
                                                swipeToDeleteTip.invalidate(reason: .actionPerformed)
                                            } label: {
                                                Label("Hapus", systemImage: "trash")
                                            }
                                            .tint(.red)
                                            .accessibilityLabel(
                                                "Hapus obat \(obat.nama)")
                                            .accessibilityHint("Ketuk dua kali untuk menghapus obat ini")
                                            
                                        }
                                        .popoverTip(index == 0 ? swipeToDeleteTip : nil)
                                }
                            }
                        }
                        .listStyle(.insetGrouped)
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $showAddSheet) {
                ObatAddView()
                    .interactiveDismissDisabled()
            }
        }
        .onChange(of: allObat.count) { oldValue, newValue in
            if oldValue == 0 && newValue == 1 && !hasShownSwipeDeleteTip {
                SwipeToDeleteTip.shouldShow = true
                hasShownSwipeDeleteTip = true
                 
                Task {
                    try? await Task.sleep(for: .seconds(8))
                    swipeToDeleteTip.invalidate(reason: .tipClosed)
                    }
            }
        }
        .alert("Hapus Obat?", isPresented: $showDeleteAlert) {

            Button("Batal", role: .cancel) {
                obatToDelete = nil
            }
                .tint(.black)
                .accessibilityLabel("Batal, jangan hapus obat")

            Button("Hapus", role: .destructive) {
                if let obat = obatToDelete {
                    modelContext.delete(obat)

                    do {
                        try modelContext.save()
                    } catch {
                        print("Gagal menghapus obat: \(error)")
                    }
                    WidgetCenter.shared.reloadTimelines(ofKind: "ObatWidget")
                    obatToDelete = nil
                }
            }
            .accessibilityLabel(
                Text("Hapus obat \(obatToDelete?.nama ?? "")")
            )

        } message: {
            Text("Apakah anda yakin untuk menghapus obat ini?")
        }
        .spokenIn("id_ID")
    }
}

#Preview {
    ObatListView()
        .modelContainer(for: Obat.self, inMemory: true)
}
