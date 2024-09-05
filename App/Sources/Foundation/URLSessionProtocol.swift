//
//  URLSessionProtocol.swift
//  Recipes
//
//  Created by Peter Schuette on 9/5/24.
//

import Foundation

/// @mockable
protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol { }
