import SwiftUI

import Constant
import Model
import StyleGuide

public struct SpecificDateDataView: View {

    // Specific date data
    private let selectedDate: Date
    private var stepCount: StepCount = .noData
    private var walkingSpeed: WalkingSpeed = .noData
    private var walkingStepLength: WalkingStepLength = .noData

    private let formatter: DateFormatter

    public init(
        selectedDate: Date,
        stepCount: StepCount,
        walkingSpeed: WalkingSpeed,
        walkingStepLength: WalkingStepLength
    ) {
        self.selectedDate = selectedDate
        self.stepCount = stepCount
        self.walkingSpeed = walkingSpeed
        self.walkingStepLength = walkingStepLength

        formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
    }

    public var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(Color.adaptiveWhite)
                .cornerRadius(20)
                .adaptiveShadow()

            VStack(alignment: .leading, spacing: 24) {
                Text("\(formatter.string(from: selectedDate))のデータ")
                    .adaptiveFont(.bold, size: 18)

                VStack(alignment: .leading, spacing: 8) {
                    specificDateDataRowView(title: "👣 歩数", detail: "\(stepCount.number)歩")
                    specificDateDataRowView(title: "💨 平均歩行速度", detail: String(format: "%.2fm/s", walkingSpeed.speed))
                    specificDateDataRowView(title: "📏 平均歩幅", detail: String(format: "%.2fm", walkingStepLength.length))
                }
            }
            .padding(.horizontal, 18)
        }
        .frame(height: 160)
    }
}

extension SpecificDateDataView {

    func specificDateDataRowView(title: String, detail: String) -> some View {
        HStack(spacing: 16) {
            Text(title)
                .frame(width: 170, alignment: .leading)
            Text(detail)
        }
        .adaptiveFont(.bold, size: 16)
    }
}

#if DEBUG

struct SpecificDateDataView_Previews: PreviewProvider {
    static var previews: some View {
        SpecificDateDataView(
            selectedDate: Date(),
            stepCount: .noData,
            walkingSpeed: .noData,
            walkingStepLength: .noData
        )
    }
}

#endif
