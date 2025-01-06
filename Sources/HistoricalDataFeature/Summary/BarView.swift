import SwiftUI

struct BarView: View {
    let year: Int
    let steps: Int
    let barHeight: CGFloat

    var body: some View {
        VStack(spacing: 4) {
            Text("\(steps)")
                .font(.caption)

            Capsule()
                .fill(
                    .linearGradient(
                        .init(colors: [.black.opacity(0.7), .gray]),
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .frame(width: 20, height: barHeight)
                .frame(maxWidth: 60)
            Text(String(year))
                .font(.caption)
                .bold()
        }
    }
}

#Preview {
    ScrollView(.horizontal) {
        HStack(alignment: .bottom, spacing: 16) {
            Spacer()
            BarView(
                year: 2024,
                steps: .random(in: 100...20000),
                barHeight: .random(in: 10...200)
            )
            BarView(
                year: 2025,
                steps: .random(in: 100...20000),
                barHeight: .random(in: 10...200)
            )
            Spacer()
        }
    }
}
