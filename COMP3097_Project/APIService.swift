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
    let groupCategory: String
    let image: String
}

enum APIServiceError: LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The product service URL is invalid."
        case .invalidResponse:
            return "The server returned an unexpected response."
        case .decodingFailed:
            return "The product data could not be decoded."
        }
    }
}

private struct DummyJSONProductsResponse: Decodable {
    let products: [DummyJSONProduct]
}

final class APIService {
    static let shared = APIService()
    private let session: URLSession

    private init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchProducts() async throws -> [APIProduct] {
        try await fetchProducts(matchingGroup: nil)
    }

    func fetchProducts(matchingGroup groupCategory: String?) async throws -> [APIProduct] {
        let response: DummyJSONProductsResponse = try await request(path: "/products?limit=0")
        let normalized = response.products.compactMap { product -> APIProduct? in
            guard let groupCategory = normalizedGroupCategory(for: product.category) else {
                return nil
            }

            return APIProduct(
                id: product.id,
                title: product.title,
                price: product.price,
                description: product.description,
                category: displayCategory(for: product.category),
                groupCategory: groupCategory,
                image: product.thumbnail
            )
        }

        guard let groupCategory else {
            return normalized
        }

        return normalized.filter { $0.groupCategory.caseInsensitiveCompare(groupCategory) == .orderedSame }
    }

    func fetchAvailableGroupCategories() async throws -> [String] {
        let products = try await fetchProducts()
        return Array(Set(products.map(\.groupCategory))).sorted()
    }

    private func request<Response: Decodable>(path: String) async throws -> Response {
        guard let url = URL(string: "https://dummyjson.com\(path)") else {
            throw APIServiceError.invalidURL
        }

        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw APIServiceError.invalidResponse
        }

        do {
            return try JSONDecoder().decode(Response.self, from: data)
        } catch {
            throw APIServiceError.decodingFailed
        }
    }

    private func normalizedGroupCategory(for sourceCategory: String) -> String? {
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

    private func displayCategory(for sourceCategory: String) -> String {
        switch sourceCategory {
        case "mens-shirts":
            return "Shirts"
        case "mens-shoes":
            return "Shoes"
        case "mens-watches":
            return "Watches"
        case "tops":
            return "Tops"
        case "womens-dresses":
            return "Dresses"
        case "womens-shoes":
            return "Shoes"
        case "womens-bags":
            return "Bags"
        case "womens-watches":
            return "Watches"
        case "womens-jewellery":
            return "Jewelry"
        case "sunglasses":
            return "Accessories"
        case "smartphones":
            return "Smartphones"
        case "laptops":
            return "Laptops"
        case "tablets":
            return "Tablets"
        case "mobile-accessories":
            return "Accessories"
        default:
            return sourceCategory
                .split(separator: "-")
                .map { $0.capitalized }
                .joined(separator: " ")
        }
    }
}

private struct DummyJSONProduct: Decodable {
    let id: Int
    let title: String
    let description: String
    let category: String
    let price: Double
    let thumbnail: String
}
