import AppIntents

struct PlaceEntity: AppEntity {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Place")
    static var defaultQuery = PlaceEntityQuery()

    var id: String
    var name: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
}

struct PlaceEntityQuery: EntityQuery {
    func entities(for identifiers: [PlaceEntity.ID]) async throws -> [PlaceEntity] {
        PlaceStore.loadPlaces()
            .filter { identifiers.contains($0.id) }
            .map { PlaceEntity(id: $0.id, name: $0.name) }
    }

    func suggestedEntities() async throws -> [PlaceEntity] {
        PlaceStore.loadPlaces()
            .map { PlaceEntity(id: $0.id, name: $0.name) }
    }
}

struct SelectPlaceIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Place"
    static var description = IntentDescription("Choose a place to monitor")

    @Parameter(title: "Place")
    var place: PlaceEntity?
}
