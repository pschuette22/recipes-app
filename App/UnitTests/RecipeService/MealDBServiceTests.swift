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
    private var sessionMock: URLSessionProtocolMock!
    private var service: MealDBService!

    override func setUp() {
        sessionMock = .init()
        service = MealDBService(urlSession: sessionMock)
    }
    
    override func tearDown() {
        sessionMock = nil
        service = nil
    }
    
    // MARK: - Categories fetch
    
    func testFetchCategories_withSuccess_retrievesCategories() async throws {
        let data = try Fixture.data(forResource: "GetCategories-success", withExtension: "json")
        sessionMock.dataHandler = { request in
            XCTAssertEqual(request.url?.absoluteString, "https://www.themealdb.com/api/json/v1/1/categories.php")
            return (data, .mock(status: 200))
        }
        let categories = try await service.fetchCategories()
        XCTAssertEqual(categories.count, 3)
        XCTAssertEqual(categories[1].title, "Chicken")
    }
    
    // MARK: - Meal Fetch
    
    func testFetchMeals_withSuccess_retrievesMeals() async throws {
        let data = try Fixture.data(forResource: "GetMeals-success", withExtension: "json")
        let seafood = CategoryModel(id: 123, title: "Seafood", image: URL(string: "https://some.img")!, description: "")
        sessionMock.dataHandler = { request in
            XCTAssertEqual(request.url?.absoluteString, "https://www.themealdb.com/api/json/v1/1/filter.php?c=Seafood")
            return (data, .mock(status: 200))
        }
        let meals = try await service.fetchMeals(in: seafood)
        XCTAssertEqual(meals.count, 3)
        XCTAssertEqual(meals[1].id, 52819)
        XCTAssertEqual(meals[1].title, "Cajun spiced fish tacos")
    }
}


