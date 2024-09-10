//
//  TestErrors.swift
//  Recipes
//
//  Created by Peter Schuette on 9/6/24.
//

import Foundation

enum TestError: Error, CustomStringConvertible {
    case failedToLoadResource(name: String)

    var description: String {
        switch self {
        case let .failedToLoadResource(name):
            "Failed to load resource: " + name
        }
    }
}
