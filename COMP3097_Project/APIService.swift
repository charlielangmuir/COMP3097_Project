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

final class APIService {
    static let shared = APIService()
    private init() {}

    func fetchProducts() async throws -> [APIProduct] {
        let url = URL(string: "https://fakestoreapi.com/products")!
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode([APIProduct].self, from: data)
    }
}
