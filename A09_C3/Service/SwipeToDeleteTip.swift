//
//  SwiptoDelete.swift
//  A09_C3
//
//  Created by Muhammad Dzakki Abdullah on 24/07/26.
//

import TipKit

struct SwipeToDeleteTip: Tip {
    @Parameter
    static var shouldShow: Bool = false

    var title: Text {
        Text("Geser untuk menghapus")
    }

    var message: Text? {
        Text("Geser ke kiri untuk menghapus catatan")
    }

    var image: Image? {
        Image(systemName: "hand.draw")
    }

    var rules: [Rule] {
        #Rule(Self.$shouldShow) { $0 == true }
    }
}
