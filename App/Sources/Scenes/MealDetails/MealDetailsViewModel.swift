//
//  MealDetailsViewModel.swift
//  Recipes
//
//  Created by Peter Schuette on 9/9/24.
//

import AsyncState
import Foundation

final class MealDetailsViewModel: ViewModeling {
    // -- State Definition --
    typealias State = MealDetailsState
    typealias Sections = State.Sections
    typealias Items = State.Items

    private(set) var state: State {
        didSet {
            openStateStream.send(state)
        }
    }

    // -- State Streaming --
    private var openStateStream = OpenAsyncBroadcast<State>()
    var stateStream: any AsyncBroadcast<State> {
        openStateStream
    }

    private let recipeId: Int
    private let service: any RecipeService
    private var loadTask: Task<Void, Error>?

    private var details: MealDetailModel?

    convenience init(
        summary: MealSummaryModel,
        service: any RecipeService = MealDBService()
    ) {
        self.init(
            recipeId: summary.id,
            MealDetailsState(
                photoURL: summary.image,
                title: summary.title
            ),
            service: service
        )
    }

    required init(
        recipeId: Int,
        _ initialState: State,
        service: any RecipeService = MealDBService()
    ) {
        self.recipeId = recipeId
        state = initialState
        self.service = service
    }

    deinit {
        loadTask?.cancel()
    }
}

// MARK: - ViewModeling

extension MealDetailsViewModel {
    @MainActor
    func currentState() -> State {
        state
    }
}

extension MealDetailsViewModel {
    func viewDidLoad() {
        fetchRecipeDetails()
    }

    private func fetchRecipeDetails() {
        let recipeId = recipeId
        let service = service

        loadTask = Task { [weak self] in
            guard
                let details = try? await service.fetchMeal(withId: recipeId)
            else {
                // TODO: Handle error
                return
            }
            await self?.didLoad(details)
        }
    }

    @MainActor
    func didLoad(_ details: MealDetailModel) {
        self.details = details
        let ingredients = details.ingredients.map {
            IngredientCell.Configuration(ingredient: $0.title, measurement: $0.measurement)
        }

        state.update {
            $0.set(ingredients: ingredients)
            $0.set(instructions: details.instructions)
        }
    }
}
