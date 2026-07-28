//
//  WidgetRefreshObserver.swift
//  A09_C3
//
//  Created by Muhammad Dzakki Abdullah on 28/07/26.
//

import WidgetKit
import SwiftData
import Combine

final class WidgetRefreshObserver {
    private var cancellable: AnyCancellable?

    init() {
        cancellable = NotificationCenter.default
            .publisher(for: ModelContext.didSave)
            .sink { _ in
                WidgetCenter.shared.reloadTimelines(ofKind: "ObatWidget")
            }
    }
}
