//
//  ExpandableDatePicker.swift
//  A09_C3
//
//  Created by Richie Daryl Kwenandar on 21/07/26.
//

import SwiftUI

struct ExpandableDatePicker: View {
    let label: String
    @Binding var selection: Date
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    @State private var isExpanded = false
    
    var dynamicLayout: AnyLayout {
        dynamicTypeSize.isAccessibilitySize
        ? AnyLayout(VStackLayout(alignment: .leading))
        : AnyLayout(HStackLayout(alignment: .center))
    }
    
    private var formattedDate: String {
        selection.formatted(
            .dateTime.day().month(.abbreviated).year()
            .locale(Locale(identifier: "id_ID"))
        )
    }
    
    var body: some View {
        Button {
            dismissKeyboard()
            if reduceMotion {
                isExpanded.toggle()
            } else {
                withAnimation(.easeOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            }
        } label: {
            HStack {
                dynamicLayout{
                    Text(label)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Text(formattedDate)
                        .foregroundStyle(isExpanded ? .cyan : .primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.16))
                        .clipShape(Capsule())
                        .animation(
                            reduceMotion ? nil : .easeOut(duration: 0.2),
                            value: isExpanded
                        )
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
        .accessibilityValue(accessibleFormattedDate)
        .accessibilityHint(isExpanded ? "Ketuk dua kali untuk menutup kalender" : "Ketuk dua kali untuk membuka kalender")
        .accessibilityAddTraits(isExpanded ? [.isButton] : [.isButton])
        
        if isExpanded {
            DatePicker(
                "",
                selection: $selection,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            .environment(\.locale, Locale(identifier: "id_ID"))
            .labelsHidden()
            .tint(.cyan)
            .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }
    // Format khusus untuk VoiceOver: bulan lengkap, bukan singkatan
    private var accessibleFormattedDate: String {
        selection.formatted(
            .dateTime.day().month(.wide).year()
            .locale(Locale(identifier: "id_ID"))
        )
    }
    
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
