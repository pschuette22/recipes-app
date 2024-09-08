//
//  Fixtures.swift
//  Recipes
//
//  Created by Peter Schuette on 9/6/24.
//

import Foundation

enum Fixture {
    static func data(forResource resource: String, withExtension ext: String) throws -> Data {
        guard
            let url = Bundle.module.url(forResource: resource, withExtension: ext),
            let data = FileManager.default.contents(atPath: url.path())
        else {
            throw TestError.failedToLoadResource(name: resource + "." + ext)
        }
        return data
    }
}
