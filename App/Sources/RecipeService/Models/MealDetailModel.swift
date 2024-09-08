//
//  MealDetailModel.swift
//  Recipes
//
//  Created by Peter Schuette on 9/7/24.
//

import Foundation

struct MealDetailModel: Hashable {
    struct Ingredient: Hashable {
        var title: String
        var measurement: String
    }

    var id: Int
    var title: String
    var instructions: String
    var imageURL: URL
    var youtube: URL?
    var ingredients: [Ingredient]
    var source: URL?
}
