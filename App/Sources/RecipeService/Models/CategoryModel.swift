//
//  Category.swift
//  Recipes
//
//  Created by Peter Schuette on 9/3/24.
//

import Foundation

struct Category: Hashable {
    var id: Int
    var title: String
    var image: URL
    var description: String
}
