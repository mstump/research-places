import SwiftUI

struct PlaceSearchRow: View {
    let result: SearchResult
    let onAdd: () async -> Void

    @EnvironmentObject private var store: PlaceStore
    @State private var isAdding = false

    private var alreadyMonitored: Bool {
        store.places.contains { $0.id == result.placeId }
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(result.name)
                    .font(.headline)
                Text(result.address)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if alreadyMonitored {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            } else if isAdding {
                ProgressView()
            } else {
                Button {
                    isAdding = true
                    Task {
                        await onAdd()
                        isAdding = false
                    }
                } label: {
                    Image(systemName: "plus.circle")
                        .font(.title2)
                }
                .buttonStyle(.borderless)
            }
        }
        .padding(.vertical, 4)
    }
}
