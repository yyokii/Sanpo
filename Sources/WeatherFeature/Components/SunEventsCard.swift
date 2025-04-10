import Model
import SwiftUI

struct SunEventsCard: View {
    let mainSunEvents: MainSunEvents

    var body: some View {
        VStack {
            SunEventsView(now: .now, sunEvents: mainSunEvents)
                .padding(.horizontal, 8)
            Spacer(minLength: 12).fixedSize()
            HStack(alignment: .center, spacing: 0) {
                detailDataItem(value: mainSunEvents.sunrise)
                Spacer(minLength: 8)
                detailDataItem(value: mainSunEvents.sunset)
            }
            Spacer(minLength: 8).fixedSize()
        }
    }

    func detailDataItem(value: Date) -> some View {
        Text(value, style: .time)
            .font(.small)
    }
}
