import SwiftUI

struct PlaceDetailView: View {
    let place: Place

    var body: some View {
        List {
            Section("Status") {
                if let openNow = place.openNow {
                    LabeledContent("Currently") {
                        Text(openNow ? "Open" : "Closed")
                            .foregroundStyle(openNow ? .green : .red)
                            .fontWeight(.semibold)
                    }
                }

                if let status = place.businessStatus {
                    LabeledContent("Business Status", value: status.capitalized)
                }
            }

            if let rating = place.rating {
                Section("Rating") {
                    HStack(spacing: 4) {
                        StarRatingView(rating: rating)
                        Text(String(format: "%.1f", rating))
                        if let count = place.userRatingCount {
                            Text("(\(count) reviews)")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Section("Details") {
                LabeledContent("Address", value: place.address)

                if let phone = place.phone {
                    Link(destination: URL(string: "tel:\(phone.filter { $0.isNumber || $0 == "+" })")!) {
                        LabeledContent("Phone") {
                            Text(phone)
                        }
                    }
                }

                if let uri = place.googleMapsUri, let url = URL(string: uri) {
                    Link("Open in Google Maps", destination: url)
                }
            }

            if let hours = place.weekdayHours, !hours.isEmpty {
                Section("Hours") {
                    ForEach(hours, id: \.self) { line in
                        Text(line)
                            .font(.subheadline)
                    }
                }
            }

            if let lastUpdated = place.lastUpdated {
                Section {
                    LabeledContent("Last Updated") {
                        Text(lastUpdated, style: .relative)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle(place.name)
    }
}
