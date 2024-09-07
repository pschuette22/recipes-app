//
//  RecipeService.swift
//  Recipes
//
//  Created by Peter Schuette on 9/3/24.
//

import Foundation
import SwiftRequestBuilder

/// @mockable
protocol RecipeService {
    func fetchCategories() async throws -> [CategoryModel]
    func fetchMeals(in category: CategoryModel) async throws -> [MealSummaryModel]
}

/// Handle network interactions with TheMealDB
final class MealDBService: RecipeService {
    
    private let urlSession: URLSessionProtocol
    private let decoder = JSONDecoder()
    
    init(
        urlSession: URLSessionProtocol = URLSession.shared
    ) {
        self.urlSession = urlSession
    }
}

// MARK: - MealDBService categories

extension MealDBService {
    // Response Model
    struct FetchCategoriestResponse: Response {
        struct CategoryItem: Codable, Equatable {
            enum CodingKeys: String, CodingKey {
                case id = "idCategory"
                case title = "strCategory"
                case thumbnailUrl = "strCategoryThumb"
                case description = "strCategoryDescription"
            }

            let id: String
            let title: String
            let thumbnailUrl: URL
            let description: String
            
            var asCategory: CategoryModel? {
                guard let id = Int(self.id) else { return nil }
                
                return CategoryModel(id: id, title: title, image: thumbnailUrl, description: description)
            }
        }

        @Lossy
        var categories: [CategoryItem]
    }

    
    /// Fetches a list of categories from the backend.
    /// - Returns: An array of category data models
    func fetchCategories() async throws -> [CategoryModel] {
        let request = URLRequest(EmptyBody.self) {
            HTTPMethod(.get)
            URL(string: "https://www.themealdb.com/api/json/v1/1/categories.php")!
        }
        
        let (data, _) = try await urlSession.data(for: request)
        let responseBody = try decoder.decode(FetchCategoriestResponse.self, from: data)
        
        return responseBody.categories.compactMap { $0.asCategory }
    }
}

// MARK: - MealDBService Meals

extension MealDBService {
    // Response Model
    struct FetchMealsResponse: Response {
        struct MealItem: Codable, Equatable {
            enum CodingKeys: String, CodingKey {
                case id = "idMeal"
                case title = "strMeal"
                case thumbnailUrl = "strMealThumb"
            }

            let id: String
            let title: String
            let thumbnailUrl: URL
            
            var asMeal: MealSummaryModel? {
                guard let id = Int(self.id) else { return nil }
                
                return MealSummaryModel(id: id, title: title, image: thumbnailUrl)
            }
        }

        @Lossy
        var meals: [MealItem]
    }

    func fetchMeals(in category: CategoryModel) async throws -> [MealSummaryModel] {
        let request = URLRequest(EmptyBody.self) {
            HTTPMethod(.get)
            URL(string: "https://www.themealdb.com/api/json/v1/1/filter.php")!
            QueryItem("c", value: category.title)
        }
        
        let (data, _) = try await urlSession.data(for: request)
        let responseBody = try decoder.decode(FetchMealsResponse.self, from: data)
        
        return responseBody.meals.compactMap { $0.asMeal }
    }
}
