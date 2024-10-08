//
//  ServiceError.swift
//  Recipes
//
//  Created by Peter Schuette on 9/3/24.
//

import Foundation

enum ServiceError: EquatableError {
    case decodingError(Error)
    case malformedResponse(URLRequest)

    static func == (lhs: ServiceError, rhs: ServiceError) -> Bool {
        switch (lhs, rhs) {
        case let (.decodingError(underlyingLhs), .decodingError(underlyingRhs)):
            underlyingLhs.localizedDescription == underlyingRhs.localizedDescription
        case let (.malformedResponse(underlingLhs), .malformedResponse(underlyingRhs)):
            underlingLhs == underlyingRhs
        default:
            false
        }
    }
}
