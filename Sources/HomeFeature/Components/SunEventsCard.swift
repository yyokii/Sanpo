import Model
import SwiftUI

struct SunEventsCard: View {
    let mainSunEvents: MainSunEvents

    var body: some View {
        CardView {
            HStack(alignment: .center, spacing: 8) {
                Image(systemName: "sun.haze")
                    .adaptiveFont(.bold, size: 16)
                Text("Sun Events")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .adaptiveFont(.bold, size: 16)
            }
            SunEventsView(now: .now, sunEvents: mainSunEvents)
                .padding(.horizontal, 8)
            Spacer(minLength: 12).fixedSize()
            HStack(alignment: .center, spacing: 0) {
                detailDataItem(title: "Sunrise", value: mainSunEvents.sunrise)
                Spacer(minLength: 8)
                detailDataItem(title: "Sunset", value: mainSunEvents.sunset)
            }
            Spacer(minLength: 8).fixedSize()
        }
    }

    func detailDataItem(title: String, value: Date) -> some View {
        VStack(alignment: .center, spacing: 8) {
            Text(title)
                .adaptiveFont(.normal, size: 12)
                .foregroundStyle(.black)
            Text(value, style: .time)
                .adaptiveFont(.bold, size: 16)
        }
    }
}
