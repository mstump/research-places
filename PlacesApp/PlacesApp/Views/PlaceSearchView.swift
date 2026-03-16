import SwiftUI

struct PlaceSearchView: View {
    @EnvironmentObject private var store: PlaceStore
    @State private var query = ""
    @State private var results: [SearchResult] = []
    @State private var isSearching = false
    @State private var errorMessage: String?

    private let client = PlacesAPIClient()

    var body: some View {
        NavigationStack {
            List {
                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                    }
                }

                ForEach(results) { result in
                    PlaceSearchRow(result: result) {
                        await addPlace(result)
                    }
                }
            }
            .navigationTitle("Search Places")
            .searchable(text: $query, prompt: "Search for a business")
            .onSubmit(of: .search) {
                Task { await performSearch() }
            }
            .overlay {
                if isSearching {
                    ProgressView()
                } else if results.isEmpty && !query.isEmpty {
                    ContentUnavailableView.search(text: query)
                }
            }
        }
    }

    private func performSearch() async {
        guard !query.isEmpty else { return }
        isSearching = true
        errorMessage = nil
        do {
            results = try await client.search(query: query)
        } catch {
            errorMessage = error.localizedDescription
        }
        isSearching = false
    }

    private func addPlace(_ result: SearchResult) async {
        guard !store.places.contains(where: { $0.id == result.placeId }) else { return }
        do {
            let details = try await client.getPlaceDetails(placeId: result.placeId)
            let place = Place(
                id: details.placeId,
                name: details.name,
                address: details.address,
                rating: details.rating,
                userRatingCount: details.userRatingCount,
                businessStatus: details.businessStatus,
                openNow: details.openNow,
                phone: details.phone,
                weekdayHours: details.weekdayHours,
                googleMapsUri: details.googleMapsUri,
                lastUpdated: Date()
            )
            store.add(place)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
