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
        case ingredient(IngredientCell.Configuration)
        case instructions(InstructionsCell.Configuration)
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
        sectionItems.forEach { section, _ in
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

extension MealDetailsState {
    mutating
    func set(ingredients: [IngredientCell.Configuration]) {
        if !sections.contains(.ingredients) {
            sections.insert(.ingredients, at: 0)
        }
        sectionItems[.ingredients] = ingredients.map { .ingredient($0) }
    }

    mutating
    func set(instructions: String) {
        if !sections.contains(.instructions) {
            sections.append(.instructions)
        }
        sectionItems[.instructions] = [.instructions(.init(instructions: instructions))]
    }
}
