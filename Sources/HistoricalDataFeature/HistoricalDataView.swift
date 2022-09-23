import SwiftUI

import Model

public struct HistoricalDataView: View {
    @EnvironmentObject var myGoalStore: MyGoalStore

    public init() {}

    public var body: some View {
        VStack(spacing: 8) {
            Text("HistoricalData View")

            CalendarView(
                stepCounts: [],
                myGoal: myGoalStore) { date in
                    print(date)
                }
        }
        .padding()
    }
}
