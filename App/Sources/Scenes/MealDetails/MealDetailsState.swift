// 
//  MealDetailsState.swift
//  Recipes
//
//  Created by Peter Schuette on 9/9/24.
//

import AsyncState
import Foundation
import UIKit

struct MealDetailsState: CollectionViewState {
    enum Sections: Hashable, Sendable {
        case ingredients
        case instructions
    }

    enum Items: Hashable, Sendable {
        case photo(URL)
    }
    
    let photoURL: URL
    let title: String
    
    /// Ordered array of Sections for current state
    private(set) var sections: [Sections] = []

    /// Map of items per section
    private(set) var sectionItems: [Sections: [Items]] = [:]
        
    init(photoURL: URL, title: String) {
        self.photoURL = photoURL
        self.title = title
    }
}

extension MealDetailsState {
    /// Compute the snapshot based on collection state
    var snapshot: NSDiffableDataSourceSnapshot<Sections, Items> {
        var snapshot = NSDiffableDataSourceSnapshot<Sections, Items>()
        snapshot.appendSections(sections)
        sectionItems.forEach { section, items in
            guard let items = sectionItems[section] else { return }

            snapshot.appendItems(items, toSection: section)
        }
        // Add additional customizations as needed
        return snapshot
    }
}

extension MealDetailsState {
    // TODO: Define transactions
}
