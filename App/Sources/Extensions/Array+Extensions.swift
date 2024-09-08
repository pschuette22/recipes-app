//
//  Array+Extensions.swift
//  Recipes
//
//  Created by Peter Schuette on 9/7/24.
//

import Foundation

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
