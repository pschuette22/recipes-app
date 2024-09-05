//
//  RecipeService.swift
//  Recipes
//
//  Created by Peter Schuette on 9/3/24.
//

import Foundation
import SwiftRequestBuilder

protocol RecipeService {
    func fetchCategories() async throws -> [Category]
}

/// Handle network interactions with TheMealDB
final class MealDBService: RecipeService {
    
    private let urlSession: URLSession
    private let decoder = JSONDecoder()
    
    init(
        urlSession: URLSession = .shared
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
            
            var asCategory: Category? {
                guard let id = Int(self.id) else { return nil }
                
                return Category(id: id, title: title, image: thumbnailUrl, description: description)
            }
        }

        let categories: [CategoryRequestItem]
    }

    
    /// Fetches a list of categories from the backend.
    /// - Returns: An array of category data models
    func fetchCategories() async throws -> [Category] {
        let request = URLRequest(EmptyBody.self) {
            HTTPMethod(.get)
            URL(string: "https://www.themealdb.com/api/json/v1/1/categories.php")!
        }
        
        let (data, _) = try await urlSession.data(for: request)
        let responseBody = try decoder.decode(FetchCategoriestResponse.self, from: data)
        
        return responseBody.categories.compactMap { $0.asCategory }
    }
}
