import SwiftUI

struct MonitoredPlacesView: View {
    @EnvironmentObject private var store: PlaceStore
    @State private var isRefreshing = false

    private let client = PlacesAPIClient()

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.places) { place in
                    NavigationLink(value: place) {
                        PlaceRow(place: place)
                    }
                }
                .onDelete(perform: delete)
            }
            .navigationTitle("Monitored Places")
            .navigationDestination(for: Place.self) { place in
                PlaceDetailView(place: place)
            }
            .refreshable {
                await refreshAll()
            }
            .overlay {
                if store.places.isEmpty {
                    ContentUnavailableView(
                        "No Places",
                        systemImage: "mappin.slash",
                        description: Text("Search and add places to monitor")
                    )
                }
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            store.remove(id: store.places[index].id)
        }
    }

    private func refreshAll() async {
        for place in store.places {
            do {
                let details = try await client.getPlaceDetails(placeId: place.id)
                var updated = place
                updated.rating = details.rating
                updated.userRatingCount = details.userRatingCount
                updated.businessStatus = details.businessStatus
                updated.openNow = details.openNow
                updated.phone = details.phone
                updated.weekdayHours = details.weekdayHours
                updated.googleMapsUri = details.googleMapsUri
                updated.lastUpdated = Date()
                store.update(updated)
            } catch {
                // Skip failed updates silently
            }
        }
    }
}

private struct PlaceRow: View {
    let place: Place

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(place.name)
                    .font(.headline)
                Spacer()
                if let openNow = place.openNow {
                    Text(openNow ? "Open" : "Closed")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(openNow ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                        .foregroundStyle(openNow ? .green : .red)
                        .clipShape(Capsule())
                }
            }

            Text(place.address)
                .font(.caption)
                .foregroundStyle(.secondary)

            if let rating = place.rating {
                HStack(spacing: 4) {
                    StarRatingView(rating: rating)
                    if let count = place.userRatingCount {
                        Text("(\(count))")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}
