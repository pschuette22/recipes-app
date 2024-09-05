//
//  MealDBServiceTests.swift
//  Recipes
//
//  Created by Peter Schuette on 9/5/24.
//

import Foundation
import XCTest
@testable import Recipes

final class MealDBServiceTests: XCTestCase {
    private var service: MealDBService!
    
    override func setUp() {
        service = MealDBService(urlSession: .shared)
    }
}
