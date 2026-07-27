//
//  EmptyStateView.swift
//  A09_C3
//
//  Created by Richie Daryl Kwenandar on 17/07/26.
//

import SwiftUI

struct EmptyStateView: View {
    let message: String
    
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    var isAccessibilitySize: Bool {
        dynamicTypeSize.isAccessibilitySize
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "pencil.and.list.clipboard")
                .font(.system(size: 110, weight: .semibold))
                .foregroundStyle(.secondary)
            
            Text("Belum ada data")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message)
        .spokenIn("id_ID")
    }
}

#Preview {
    ZStack {
        Color("backgroundColor")
            .ignoresSafeArea()
        EmptyStateView(message: "Ketuk tombol tambah untuk mencatat pantauan")
    }
}
