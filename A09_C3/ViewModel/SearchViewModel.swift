//
//  SearchViewModel.swift
//  A09_C3
//
//  Created by Richie Daryl Kwenandar on 21/07/26.
//

import SwiftData
import Observation
import Foundation

@Observable
final class SearchViewModel {
    private let modelContext: ModelContext
    let historyStore: SearchHistoryStore
    
    init(modelContext: ModelContext, historyStore: SearchHistoryStore) {
        self.modelContext = modelContext
        self.historyStore = historyStore
    }
    
    func groupedResults(for query: String) -> [(category: SearchCategory, items: [SearchResultItem])] {
        let obatResults = searchObat(matching: query)
        let pantauanResults = searchPantauan(matching: query)
        let konsulResults = searchKonsul(matching: query)
        
        return [
            (.obat, obatResults),
            (.pantauan, pantauanResults),
            (.konsultasi, konsulResults)
        ].filter { !$0.items.isEmpty }
    }
    
    func searchObat(matching keyword: String) -> [SearchResultItem] {
        let all = (try? modelContext.fetch(FetchDescriptor<Obat>())) ?? []
        return all
            .filter { $0.nama.localizedStandardContains(keyword) }
            .map { obat in
                let dosisWithUnit: String = {
                    switch obat.jenis {
                    case .tablet, .kapsul: return "\(obat.dosis) mg"
                    case .sirup: return "\(obat.dosis) ml"
                    }
                }()
                
                return SearchResultItem(
                    category: .obat,
                    primaryText: obat.nama,
                    secondaryText: obat.frekuensi,
                    contextText: "\(obat.keterangan.rawValue) · \(dosisWithUnit)",
                    destination: .obat(obat)
                )
            }
    }
    
    func searchPantauan(matching keyword: String) -> [SearchResultItem] {
        let all = (try? modelContext.fetch(FetchDescriptor<PantauanModel>())) ?? []
        return all
            .filter { $0.pantauanBody.localizedStandardContains(keyword) }
            .map { pantauan in
                SearchResultItem(
                    category: .pantauan,
                    primaryText: pantauan.pantauanDate.formatted(
                        .dateTime.day().month(.wide).year().locale(Locale(identifier: "id_ID"))
                    ),
                    secondaryText: pantauan.pantauanBody,
                    contextText: nil,
                    destination: .pantauan(pantauan)
                )
            }
    }
    
    func searchKonsul(matching keyword: String) -> [SearchResultItem] {
        let all = (try? modelContext.fetch(FetchDescriptor<KonsulModel>())) ?? []
        return all
            .filter {
                $0.namaDokter.localizedStandardContains(keyword) ||
                $0.content.localizedStandardContains(keyword)
            }
            .map { konsul in
                let tanggal = konsul.tanggalKonsultasi.formatted(
                    .dateTime
                        .day()
                        .month(.twoDigits)
                        .year(.twoDigits)
                )
                
                return SearchResultItem(
                    category: .konsultasi,
                    primaryText: konsul.namaDokter,
                    secondaryText: "\(tanggal) \(konsul.content)",
                    contextText: nil,
                    destination: .konsul(konsul)
                )
            }
    }
}
