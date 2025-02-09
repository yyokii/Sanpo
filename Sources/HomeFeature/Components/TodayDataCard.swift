import SwiftUI

struct TodayDataCard: View {

    let stepCount: Int
    let yesterdayStepCount: Int
    let distance: Int
    let backgroundImageName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center, spacing: 8) {
                Image(systemName: "figure.walk")
                    .adaptiveFont(.bold, size: 12)
                    .foregroundStyle(.white)
                Text("Today")
                    .adaptiveFont(.bold, size: 12)
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(.black.opacity(0.2))
            .clipShape(.rect(cornerRadius: 12))
            .padding(.horizontal, 12)

            VStack(alignment: .center, spacing: 0) {
                Text("\(stepCount)")
                    .adaptiveFont(.bold, size: 42)
                Text("steps")
                    .adaptiveFont(.bold, size: 16)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 24)
            .padding(.bottom, 12)

            LazyVGrid(
                columns: Array(repeating: .init(.flexible(), spacing: 0, alignment: .top), count: 2),
                spacing: 24
            ) {
                detailDataItem(
                    title: "Distance",
                    value: distance,
                    unit: "m"
                )
                detailDataItem(
                    title: "Yesterday",
                    value: yesterdayStepCount,
                    unit: "steps"
                )
            }
            .padding(.vertical, 8)
            .background(.black.opacity(0.3))
            .clipShape(.rect(cornerRadius: 12))
            .padding(.horizontal, 16)
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .padding(.top, 12)
        .padding(.bottom, 16)
        .background {
            Image(backgroundImageName, bundle: .module)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .adaptiveShadow()
    }

    func detailDataItem(title: String, value: Int, unit: String) -> some View {
        VStack(alignment: .center, spacing: 8) {
            Text(title)
                .adaptiveFont(.normal, size: 12)
                .foregroundStyle(.white)
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text("\(value)")
                    .adaptiveFont(.bold, size: 16)
                Text(unit)
                    .adaptiveFont(.normal, size: 12)
            }
        }
    }
}
