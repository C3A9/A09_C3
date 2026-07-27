//
//  RingkasanSectionView.swift
//  A09_C3
//
//  Created by Muhammad Dzakki Abdullah on 22/07/26.
//

import SwiftUI

struct RingkasanSectionView: View {
    let title: String
    let lastUpdated: Date?
    let poinPenting: [String]
    let isGenerating: Bool
    let error: String?
    
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var dynamicLayout: AnyLayout {
        dynamicTypeSize.isAccessibilitySize
        ? AnyLayout(VStackLayout(alignment: .leading, spacing: 4))
        : AnyLayout(HStackLayout(alignment: .center))
    }
    
    private var accessibilityContentLabel: String {
        if isGenerating {
            return "Sedang membuat ringkasan"
        } else if let error {
            return "Gagal membuat ringkasan: \(error)"
        } else if poinPenting.isEmpty {
            return "Belum ada ringkasan"
        } else {
            let cleanedPoints = poinPenting.map {
                $0.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            return cleanedPoints.joined(separator: ". ")
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            dynamicLayout {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                if !dynamicTypeSize.isAccessibilitySize {
                    Spacer()
                }
                RelativeTimeText(date: lastUpdated)
                
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Ringkasan \(title)")
            .accessibilityValue(
                lastUpdated != nil
                ? "Diperbarui \(lastUpdated!.formatted(.relative(presentation: .named)))"
                : "Belum pernah diperbarui"
            )
            .spokenIn("id_ID")

            VStack(alignment: .leading, spacing: 10) {
                if isGenerating {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 8)
                        .accessibilityLabel("Sedang membuat ringkasan")
                } else if let error {
                    Text(error)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .accessibilityLabel("Gagal membuat ringkasan")
                } else if poinPenting.isEmpty {
                    Text("Belum ada ringkasan")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(poinPenting, id: \.self) { poin in
                        let cleanedPoin = poin.trimmingCharacters(in: .whitespacesAndNewlines)
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text("-")
                                .frame(width: 12, alignment: .leading)
                            Text(cleanedPoin)
                        }
                        .font(.body)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(accessibilityContentLabel)
            .spokenIn("id_ID")
        }
    }
}
