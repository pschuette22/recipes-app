//
//  Lossy.swift
//  Recipes
//
//  Created by Peter Schuette on 9/6/24.
//

import Foundation

@propertyWrapper struct Lossy<Element: Decodable>: Decodable {
    var wrappedValue: Array<Element>
    
    init(from decoder: any Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var decodableElements = [Element]()
        while !container.isAtEnd {
            do {
                let next = try container.decode(Element.self)
                decodableElements.append(next)
            } catch {
                // Failed to decode element, moving on
                continue
            }
        }
        wrappedValue = decodableElements
    }
}

extension Lossy: Encodable where Element: Encodable {}

extension Lossy: Equatable where Element: Equatable {}

extension Lossy: Hashable where Element: Hashable {}
