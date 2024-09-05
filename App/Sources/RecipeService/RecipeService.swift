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
    // Respons Model
    struct FetchCategoriestResponse: Response {
        struct CategoryRequestItem: Codable, Equatable {
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

        let categories: [CategoryRequestItem]
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
