//
//  QuickAction.swift
//  FoodPin
//
//  Created by Roger Florat on 18/04/18.
//  Copyright © 2018 Roger Florat. All rights reserved.
//

import Foundation

enum QuickAction: String {
    case OpenFavorites = "OpenFavorites"
    case OpenDiscover = "OpenDiscover"
    case NewRestaurant = "NewRestaurant"

    init?(fullIdentifier: String) {
        guard let shortcutIdentifier = fullIdentifier.components(separatedBy: ".").last else { return nil }
        self.init(rawValue: shortcutIdentifier)
    }
}
