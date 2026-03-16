import SwiftUI
import WidgetKit

struct PlaceWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: PlaceWidgetEntry

    var body: some View {
        if let place = entry.place {
            switch family {
            case .systemSmall:
                SmallPlaceView(place: place)
            default:
                MediumPlaceView(place: place)
            }
        } else {
            VStack {
                Image(systemName: "mappin.slash")
                    .font(.title)
                    .foregroundStyle(.secondary)
                Text("Select a place")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct SmallPlaceView: View {
    let place: Place

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(place.name)
                .font(.headline)
                .lineLimit(2)

            Spacer()

            if let openNow = place.openNow {
                Text(openNow ? "Open" : "Closed")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(openNow ? .green : .red)
            }

            if let rating = place.rating {
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                    Text(String(format: "%.1f", rating))
                        .font(.caption)
                    if let count = place.userRatingCount {
                        Text("(\(count))")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct MediumPlaceView: View {
    let place: Place

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(place.name)
                    .font(.headline)
                    .lineLimit(2)

                if let openNow = place.openNow {
                    Text(openNow ? "Open" : "Closed")
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(openNow ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                        .foregroundStyle(openNow ? .green : .red)
                        .clipShape(Capsule())
                }

                Spacer()

                if let rating = place.rating {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                        Text(String(format: "%.1f", rating))
                            .font(.caption)
                        if let count = place.userRatingCount {
                            Text("(\(count))")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 4) {
                if let hours = place.weekdayHours {
                    let todayIndex = (Calendar.current.component(.weekday, from: Date()) + 5) % 7
                    if todayIndex < hours.count {
                        Text(hours[todayIndex])
                            .font(.caption2)
                            .lineLimit(2)
                    }
                }

                Spacer()

                Text(place.address)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
    }
}
