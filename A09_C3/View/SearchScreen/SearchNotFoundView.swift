//
//  SearchNotFoundView.swift
//  A09_C3
//
//  Created by Richie Daryl Kwenandar on 21/07/26.
//

import SwiftUI

struct SearchNotFoundView: View {
    let query: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40, weight: .regular))
                .foregroundStyle(.secondary)

            Text("Tidak ada hasil untuk “\(query)”")
                .font(.headline)
                .multilineTextAlignment(.center)

            Text("Periksa ejaan atau coba gunakan kata kunci lain")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Tidak ada hasil untuk \(query). Periksa ejaan atau coba gunakan kata kunci lain")
    }
}

#Preview {
    ZStack {
        Color("backgroundColor").ignoresSafeArea()
        SearchNotFoundView(query: "Metformin")
    }
}
