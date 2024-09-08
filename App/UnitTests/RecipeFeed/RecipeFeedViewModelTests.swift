//
//  RecipeFeedViewModelTests.swift
//  Recipes
//
//  Created by Peter Schuette on 9/6/24.
//

import Foundation
import XCTest
@testable import Recipes

final class RecipeFeedViewModelTests: XCTestCase {
    private var service: RecipeServiceMock!
    private var viewModel: RecipeFeedViewModel!
    
    override func setUp() {
        service = .init()
        viewModel = RecipeFeedViewModel(
            selectedCategoryIndex: -1,
            recipeService: service
        )
    }
    
    func testViewDidLoad_fetchesCategories() async throws {
        
        let receivedLoadingState = XCTestExpectation(description: "view model entered loading state")
        let receivedLoadedState = XCTestExpectation(description: "view model entered loaded state")
        service.fetchCategoriesHandler = {
            
            return [CategoryModel(id: 123, title: "Some Category", image: URL(string: "https://some.img")!, description: "some description")]
        }
        
        let stateObserver = Task {
            var stateStream = viewModel.stateStream.observe().makeAsyncIterator()
            while let state = await stateStream.next() {
                if state.isLoadingCategories {
                    receivedLoadingState.fulfill()
                } else if let item = state.sectionItems[.categories]?[0], case let .category(configuration) = item {
                    XCTAssertEqual(configuration.title, "Some Category")
                    receivedLoadedState.fulfill()
                }
            }
        }
        
        viewModel.viewDidLoad()
        // Assert we hit begin loading
        await fulfillment(of: [receivedLoadingState], timeout: 0.1)
        // Received loaded state next
        // Enforces order
        await fulfillment(of: [receivedLoadedState], timeout: 0.1)

        stateObserver.cancel()
    }
}
