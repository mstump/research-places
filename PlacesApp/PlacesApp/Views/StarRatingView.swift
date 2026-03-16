import SwiftUI

struct StarRatingView: View {
    let rating: Double

    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: starImage(for: star))
                    .font(.caption2)
                    .foregroundStyle(.orange)
            }
        }
    }

    private func starImage(for star: Int) -> String {
        let value = rating - Double(star - 1)
        if value >= 1 {
            return "star.fill"
        } else if value >= 0.5 {
            return "star.leadinghalf.filled"
        } else {
            return "star"
        }
    }
}
