//
//  URLResponse.swift
//  UnitTests
//
//  Created by Peter Schuette on 9/6/24.
//

import Foundation

extension URLResponse {
    static func mock(status: Int) -> URLResponse {
        HTTPURLResponse(
            url: URL(string: "https://some.url")!, statusCode: status, httpVersion: nil, headerFields: nil
        )!
    }
}
