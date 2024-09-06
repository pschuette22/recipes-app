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
    
    private var categories: [CategoryModel] = []
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
    
    func viewDidLoad() {
        fetchCategories()
    }
}

// MARK: - Category Interactions

extension RecipeFeedViewModel {
    private func fetchCategories() {
        state.setIsLoadingCategories()
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
    private func update(categories: [CategoryModel]) {
        self.categories = categories

        let configurations = categories.map {
            CategoryCell.Configuration(
                url: $0.image,
                title: $0.title,
                isSelected: $0.id == selectedCategoryId
            )
        }

        self.state.update {
            $0.setDidLoadCategories(withConfigurations: configurations)
        }
    }
}
