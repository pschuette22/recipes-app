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

    // Category Management
    private var categories: [CategoryModel] = []
    private var selectedCategoryIndex: Int

    // Meal Management
    private var fetchMealsTask: Task<Void, Error>?
    private var meals: [MealSummaryModel] = []

    required init(
        _ initialState: State = .init(),
        selectedCategoryIndex: Int = 0,
        recipeService: any RecipeService = MealDBService()
    ) {
        state = initialState
        self.selectedCategoryIndex = selectedCategoryIndex
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
    private func updateCategoryCellModels() {
        let configurations = categories.map {
            CategoryCell.Configuration(
                image: $0.image,
                title: $0.title,
                isSelected: $0.id == categories[safe: selectedCategoryIndex]?.id
            )
        }

        state.update {
            $0.setDidLoadCategories(withConfigurations: configurations)
        }
    }

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
        updateCategoryCellModels()
        fetchMeals()
    }

    func didSelectCategory(at index: Int) {
        guard
            index != selectedCategoryIndex,
            categories.indices.contains(index)
        else { return }

        selectedCategoryIndex = index
        updateCategoryCellModels()
        fetchMeals()
    }
}

// MARK: - Meal Interactions 

extension RecipeFeedViewModel {
    ///  Fetches meals for the selected category
    func fetchMeals() {
        guard let category = categories[safe: selectedCategoryIndex] else { return }

        state.setIsLoadingMeals()
        fetchMealsTask?.cancel()

        fetchMealsTask = Task { [weak self, recipeService] in
            do {
                let meals = try await recipeService.fetchMeals(in: category)
                await self?.update(meals: meals)
            } catch {
                print(error)
            }
        }
    }

    @MainActor
    private func update(meals: [MealSummaryModel]) {
        self.meals = meals
        let configurations = meals.map {
            MealCell.Configuration(image: $0.image, title: $0.title)
        }

        state.update {
            $0.setDidLoadMeals(withConfigurations: configurations)
        }
    }

    func viewModel(forMealAt index: Int) -> MealDetailsViewModel? {
        meals[safe: index].map { MealDetailsViewModel(summary: $0) }
    }
}
