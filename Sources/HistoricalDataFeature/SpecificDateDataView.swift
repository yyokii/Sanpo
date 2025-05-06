import SwiftUI

import Constant
import Model
import StyleGuide

public struct SpecificDateDataView: View {
    @Environment(MyDataModel.self) private var myDataModel

    let date: Date

    private static var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }

    public init(
        date: Date
    ) {
        self.date = date
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 24) {
//            Text("\(formatter.string(from: viewData.selectedDate))のデータ")
//                .adaptiveFont(.bold, size: 18)
//
//            VStack(alignment: .leading, spacing: 8) {
//                specificDateDataRowView(title: "👣 歩数", detail: "\(viewData.stepCount.number)歩")
//                specificDateDataRowView(title: "💨 平均歩行速度", detail: String(format: "%.2fm/s", viewData.walkingSpeed.speed))
//                specificDateDataRowView(title: "📏 平均歩幅", detail: String(format: "%.2fm", viewData.walkingStepLength.length))
//            }
        }
        .padding(.horizontal, 18)
    }
}

public extension SpecificDateDataView {
    struct ViewData: Identifiable {
        public var id: Date {
            selectedDate
        }
        let selectedDate: Date
        let stepCount: StepCount
        let walkingSpeed: WalkingSpeed
        let walkingStepLength: WalkingStepLength
    }

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

//struct SpecificDateDataView_Previews: PreviewProvider {
//    static var previews: some View {
//        SpecificDateDataView(
//            viewData: .init(
//                selectedDate: Date(),
//                stepCount: .noData,
//                walkingSpeed: .noData,
//                walkingStepLength: .noData
//            )
//        )
//    }
//}

#endif
