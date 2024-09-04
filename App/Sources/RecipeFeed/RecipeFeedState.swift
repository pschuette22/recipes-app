// 
//  RecipeFeedState.swift
//  Recipes
//
//  Created by Peter Schuette on 9/3/24.
//

import AsyncState
import Foundation
import UIKit

struct RecipeFeedState: CollectionViewState {
    enum Context: Hashable {
        case idle
        case loading
        case loaded
        // TODO: error state, if needed
    }

    enum Sections: Hashable, Sendable, CaseIterable {
        case categories
    }
    
    enum Items: Hashable, Sendable {
        case category(CategoryCell.Configuration)
    }
    
    /// Ordered array of Sections for current state
    private(set) var sections: [Sections] = Sections.allCases
    
    /// Map of items per section
    private(set) var sectionItems: [Sections: [Items]] = [
        .categories: []
    ]
}

extension RecipeFeedState {
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
    
    func section(at index: Int) -> Sections {
        sections[index]
    }
    
    func item(at indexPath: IndexPath) -> Items? {
        sectionItems[section(at: indexPath.section)]?[indexPath.row]
    }
}

extension RecipeFeedState {
    mutating func set(categoryCellConfigurations: [CategoryCell.Configuration]) {
        sectionItems[.categories] = categoryCellConfigurations.map { .category($0) }
    }
}
