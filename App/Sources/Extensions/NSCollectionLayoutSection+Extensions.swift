//
//  NSCollectionLayoutSection+Extensions.swift
//  Recipes
//
//  Created by Peter Schuette on 9/3/24.
//

import Foundation
import UIKit

extension NSCollectionLayoutSection {
    /// Zero size layout section
    static let empty: NSCollectionLayoutSection = .init(
        group: NSCollectionLayoutGroup(layoutSize: .init(widthDimension: .absolute(0), heightDimension: .absolute(0)))
    )
}
