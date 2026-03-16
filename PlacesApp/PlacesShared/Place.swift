import Foundation

public struct Place: Codable, Identifiable, Hashable {
    public let id: String
    public let name: String
    public let address: String
    public var rating: Double?
    public var userRatingCount: Int?
    public var businessStatus: String?
    public var openNow: Bool?
    public var phone: String?
    public var weekdayHours: [String]?
    public var googleMapsUri: String?
    public var lastUpdated: Date?

    public init(
        id: String,
        name: String,
        address: String,
        rating: Double? = nil,
        userRatingCount: Int? = nil,
        businessStatus: String? = nil,
        openNow: Bool? = nil,
        phone: String? = nil,
        weekdayHours: [String]? = nil,
        googleMapsUri: String? = nil,
        lastUpdated: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.rating = rating
        self.userRatingCount = userRatingCount
        self.businessStatus = businessStatus
        self.openNow = openNow
        self.phone = phone
        self.weekdayHours = weekdayHours
        self.googleMapsUri = googleMapsUri
        self.lastUpdated = lastUpdated
    }
}

public struct SearchResult: Codable, Identifiable {
    public var id: String { placeId }
    public let placeId: String
    public let name: String
    public let address: String
    public let types: [String]
}

public struct PlaceDetails: Codable {
    public let placeId: String
    public let name: String
    public let address: String
    public let phone: String?
    public let rating: Double?
    public let userRatingCount: Int?
    public let businessStatus: String?
    public let openNow: Bool?
    public let weekdayHours: [String]?
    public let googleMapsUri: String?
}
