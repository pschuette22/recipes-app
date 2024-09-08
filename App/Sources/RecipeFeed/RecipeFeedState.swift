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
        case meals
    }
    
    enum Items: Hashable, Sendable {
        case contentLoading(ContentLoadingCell.Configuration)
        case category(CategoryCell.Configuration)
        case meal(MealCell.Configuration)
    }
    
    /// Ordered array of Sections for current state
    private(set) var sections: [Sections] = Sections.allCases
    
    /// Map of items per section
    private(set) var sectionItems: [Sections: [Items]] = [:]

    // Loading
    private(set) var isLoadingCategories: Bool = false
    private(set) var isLoadingMeals: Bool = false
}

// MARK: - Computed Properties

extension RecipeFeedState {
    /// Compute the snapshot based on collection state
    var snapshot: NSDiffableDataSourceSnapshot<Sections, Items> {
        var snapshot = NSDiffableDataSourceSnapshot<Sections, Items>()

        for section in sections {
            guard let items = sectionItems[section] else { continue }

            snapshot.appendSections([section])
            snapshot.appendItems(items, toSection: section)
        }

        return snapshot
    }
    
    func section(at index: Int) -> Sections {
        sections[index]
    }
    
    func item(at indexPath: IndexPath) -> Items? {
        sectionItems[section(at: indexPath.section)]?[indexPath.row]
    }
}

// MARK: - Transactions

extension RecipeFeedState {
    mutating func setIsLoadingCategories() {
        isLoadingCategories = true
        sectionItems[.categories] = [.contentLoading(.init(isAnimating: true))]
    }

    mutating func setDidLoadCategories(withConfigurations cellConfigurations: [CategoryCell.Configuration]) {
        isLoadingCategories = false
        sectionItems[.categories] = cellConfigurations.map { .category($0) }
    }
    
    mutating func setIsLoadingMeals() {
        isLoadingMeals = true
        sectionItems[.meals] = [.contentLoading(.init(isAnimating: true))]
    }
    
    mutating func setDidLoadMeals(withConfigurations cellConfigurations: [MealCell.Configuration]) {
        isLoadingMeals = false
        sectionItems[.meals] = cellConfigurations.map { .meal($0) }
    }
}
