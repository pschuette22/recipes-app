//
//  RecipeSummaryModel.swift
//  Recipes
//
//  Created by Peter Schuette on 9/6/24.
//

import Foundation

struct MealSummaryModel: Codable, Hashable {
    var id: Int
    var title: String
    var image: URL
}
