//
//  APIService.swift
//  COMP3097_Project
//
//  Created by OFI on 2026-03-14.
//
import Foundation

struct APIProduct: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let price: Double
    let description: String
    let category: String
    let image: String
}

private struct DummyJSONProductsResponse: Decodable {
    let products: [DummyJSONProduct]
}

private struct DummyJSONProduct: Decodable {
    let id: Int
    let title: String
    let description: String
    let category: String
    let price: Double
    let thumbnail: String
}

final class APIService {
    static let shared = APIService()
    private init() {}

    func fetchProducts() async throws -> [APIProduct] {
        let url = URL(string: "https://dummyjson.com/products?limit=0")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(DummyJSONProductsResponse.self, from: data)

        return decoded.products.compactMap { product in
            guard let normalizedCategory = normalizedCategory(for: product.category) else {
                return nil
            }

            return APIProduct(
                id: product.id,
                title: product.title,
                price: product.price,
                description: product.description,
                category: normalizedCategory,
                image: product.thumbnail
            )
        }
    }

    private func normalizedCategory(for sourceCategory: String) -> String? {
        switch sourceCategory {
        case "mens-shirts", "mens-shoes", "mens-watches":
            return "men's clothing"
        case "tops", "womens-dresses", "womens-shoes", "womens-bags", "womens-watches":
            return "women's clothing"
        case "womens-jewellery", "sunglasses":
            return "jewelery"
        case "smartphones", "laptops", "tablets", "mobile-accessories":
            return "electronics"
        default:
            return nil
        }
    }
}
