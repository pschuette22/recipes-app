//
//  RecipeFeedViewModel.swift
//  Recipes
//
//  Created by Peter Schuette on 9/3/24.
//

import AsyncState
import Foundation

final class RecipeFeedViewModel: ViewModeling {
    // -- State Definition --
    typealias State = RecipeFeedState
    typealias Sections = State.Sections
    typealias Items = State.Items
    
    private(set) var state: State {
        didSet {
            openStateStream.send(state)
        }
    }
    
    private let recipeService: any RecipeService
    
    // -- State Streaming --
    private var openStateStream = OpenAsyncBroadcast<State>()
    var stateStream: any AsyncBroadcast<State> {
        openStateStream
    }
    
    private var categories: [Category] = []
    private var selectedCategoryId: Int?
    
    required init(
        _ initialState: State = .init(),
        recipeService: any RecipeService = MealDBService()
    ) {
        state = initialState
        self.recipeService = recipeService
    }
}

// MARK: - ViewModeling

extension RecipeFeedViewModel {
    @MainActor
    func currentState() -> State {
        state
    }
}

extension RecipeFeedViewModel {
    func viewDidLoad() {
        fetchCategories()
    }
    
    private func fetchCategories() {
        Task { [weak self, recipeService] in
            do {
                let categories = try await recipeService.fetchCategories()
                await self?.update(categories: categories)
            } catch {
                // TODO: handle errors
                print(error)
            }
        }
    }
    
    @MainActor
    private func update(categories: [Category]) {
        self.categories = categories
    }
}
