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

extension MealDBService {
    struct FetchMealDetailsResponse: Response {
        struct MealItem: Codable, Equatable {
            struct IngredientItem: Codable, Equatable {
                var ingredient: String
                var measurement: String
            }

            enum CodingKeys: String, CodingKey {
                case id = "idMeal"
                case title = "strMeal"
                case instructions = "strInstructions"
                case thumbnailURL = "strMealThumb"
                case youtubeURL = "strYoutube"
                case sourceURL = "strSource"
            }
            
            var id: Int
            var title: String
            var instructions: String
            var thumbnailURL: URL
            var youtubeURL: URL?
            var sourceURL: URL?
            var ingredients = [IngredientItem]()
            
            init(from decoder: any Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                guard let id = Int(try container.decode(String.self, forKey: .id)) else {
                    var codingPath = decoder.codingPath
                    codingPath.append(CodingKeys.id)
                    throw DecodingError.valueNotFound(
                        String.self,
                        DecodingError.Context(codingPath: codingPath, debugDescription: "required `idMeal` is missing.")
                    )
                }
                
                self.id = id
                self.title = try container.decode(String.self, forKey: .title)
                self.instructions = try container.decode(String.self, forKey: .instructions)
                self.thumbnailURL = try container.decode(URL.self, forKey: .thumbnailURL)
                self.youtubeURL = try? container.decode(URL.self, forKey: .youtubeURL)
                self.sourceURL = try? container.decode(URL.self, forKey: .sourceURL)

                let ingredientsContainer = try decoder.singleValueContainer()
                let dictionary = try ingredientsContainer.decode([String: String?].self)
                let ingredientPrefix = "strIngredient"
                for (key, value) in dictionary where key.hasPrefix(ingredientPrefix) && (value?.count ?? 0) > 0 {
                    let suffix = key.dropFirst(ingredientPrefix.count)
                    guard
                        let unwrappedValue = value.safelyUnwrapped,
                        let measurement = dictionary["strMeasure" + suffix]?.safelyUnwrapped
                    else { continue }
                    ingredients.append(.init(ingredient: unwrappedValue, measurement: measurement))
                }
            }
                        
        }
        
        var meals: [MealItem]
    }
}

private extension Optional where Wrapped == String {
    var safelyUnwrapped: String? {
        switch self {
        case .none:
            return nil
        case .some(let str):
            return str
        }
    }
}
