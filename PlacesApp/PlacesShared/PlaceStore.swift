import Foundation

public final class PlaceStore: ObservableObject {
    @Published public var places: [Place] = []

    private let defaults: UserDefaults

    public init() {
        defaults = UserDefaults(suiteName: Constants.appGroupID) ?? .standard
        places = Self.loadPlaces(from: defaults)
    }

    public func add(_ place: Place) {
        guard !places.contains(where: { $0.id == place.id }) else { return }
        places.append(place)
        save()
    }

    public func remove(id: String) {
        places.removeAll { $0.id == id }
        save()
    }

    public func update(_ place: Place) {
        guard let index = places.firstIndex(where: { $0.id == place.id }) else { return }
        places[index] = place
        save()
    }

    public func save() {
        guard let data = try? JSONEncoder().encode(places) else { return }
        defaults.set(data, forKey: Constants.monitoredPlacesKey)
    }

    public static func loadPlaces(
        from defaults: UserDefaults? = nil
    ) -> [Place] {
        let store = defaults ?? UserDefaults(suiteName: Constants.appGroupID) ?? .standard
        guard let data = store.data(forKey: Constants.monitoredPlacesKey),
              let places = try? JSONDecoder().decode([Place].self, from: data)
        else { return [] }
        return places
    }
}
