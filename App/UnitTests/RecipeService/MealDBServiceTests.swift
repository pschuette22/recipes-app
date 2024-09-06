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
    
    private func fetchCategoryResponse_success() throws -> Data {
        guard
            let url = Bundle.module.url(forResource: "GetCategories-success", withExtension: "json"),
            let data = FileManager.default.contents(atPath: url.path())
        else {
            throw TestError.failedToLoadResource(name: "GetCategory-success.json")
        }
        return data
    }
    
    func testFetchCategories_withSuccess_retrievesCategories() async throws {
        let data = try fetchCategoryResponse_success()
        sessionMock.dataHandler = { request in
            XCTAssertEqual(request.url?.absoluteString, "https://www.themealdb.com/api/json/v1/1/categories.php")
            return (data, .mock(status: 200))
        }
        let categories = try await service.fetchCategories()
        XCTAssertEqual(categories.count, 3)
        XCTAssertEqual(categories[1].title, "Chicken")
    }
}


