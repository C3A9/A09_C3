//
//  ObatWidget.swift
//  ObatWidgetExtension
//
//  Created by Muhammad Dzakki Abdullah on 27/07/26.
//

import WidgetKit
import SwiftUI

struct ObatWidget: Widget {
    let kind: String = "ObatWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ObatWidgetProvider()) { entry in
            ObatWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Daftar Obat")
        .description("Lihat daftar obat rutin dan kondisional tanpa membuka app.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
