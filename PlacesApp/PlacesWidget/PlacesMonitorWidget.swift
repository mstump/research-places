import AppIntents
import SwiftUI
import WidgetKit

struct PlaceWidgetEntry: TimelineEntry {
    let date: Date
    let place: Place?
}

struct PlacesTimelineProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> PlaceWidgetEntry {
        PlaceWidgetEntry(date: .now, place: Place(
            id: "placeholder",
            name: "Business Name",
            address: "123 Main St",
            rating: 4.5,
            userRatingCount: 100,
            openNow: true
        ))
    }

    func snapshot(for configuration: SelectPlaceIntent, in context: Context) async -> PlaceWidgetEntry {
        let place = resolvePlace(for: configuration)
        return PlaceWidgetEntry(date: .now, place: place)
    }

    func timeline(for configuration: SelectPlaceIntent, in context: Context) async -> Timeline<PlaceWidgetEntry> {
        var place = resolvePlace(for: configuration)

        if let placeId = place?.id {
            if let details = try? await PlacesWidgetAPIClient.fetchDetails(placeId: placeId) {
                place?.rating = details.rating
                place?.userRatingCount = details.userRatingCount
                place?.businessStatus = details.businessStatus
                place?.openNow = details.openNow
                place?.weekdayHours = details.weekdayHours
                place?.lastUpdated = Date()
            }
        }

        let entry = PlaceWidgetEntry(date: .now, place: place)
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: .now)!
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }

    private func resolvePlace(for configuration: SelectPlaceIntent) -> Place? {
        guard let entity = configuration.place else { return nil }
        return PlaceStore.loadPlaces().first { $0.id == entity.id }
    }
}

struct PlacesMonitorWidget: Widget {
    let kind = "PlacesMonitorWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: SelectPlaceIntent.self,
            provider: PlacesTimelineProvider()
        ) { entry in
            PlaceWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Place Monitor")
        .description("Monitor a place's business info")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

enum PlacesWidgetAPIClient {
    static func fetchDetails(placeId: String) async throws -> PlaceDetails {
        guard let url = URL(string: "\(Constants.workerBaseURL)/api/place/\(placeId)") else {
            throw URLError(.badURL)
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(PlaceDetails.self, from: data)
    }
}
