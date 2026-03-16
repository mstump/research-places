import Foundation

final class PlacesAPIClient {
    private let baseURL: String

    init(baseURL: String = Constants.workerBaseURL) {
        self.baseURL = baseURL
    }

    func search(query: String) async throws -> [SearchResult] {
        guard var components = URLComponents(string: "\(baseURL)/api/search") else {
            throw URLError(.badURL)
        }
        components.queryItems = [URLQueryItem(name: "query", value: query)]
        guard let url = components.url else { throw URLError(.badURL) }

        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([SearchResult].self, from: data)
    }

    func getPlaceDetails(placeId: String) async throws -> PlaceDetails {
        guard let url = URL(string: "\(baseURL)/api/place/\(placeId)") else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(PlaceDetails.self, from: data)
    }
}
