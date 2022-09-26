import SwiftUI

import Model
import Constant

struct CalendarView: UIViewRepresentable {
    private let stepCounts: [Date: StepCount]
    @AppStorage(
        UserDefaultsKey.dailyTargetSteps.rawValue,
        store: UserDefaults.app
    )
    private var dailyTargetSteps: Int = 0
    private let selectDateAction: (Date) -> Void
    private let calendar = Calendar.current

    init(
        stepCounts: [Date: StepCount],
        selectDateAction: @escaping (Date) -> Void
    ) {
        self.stepCounts = stepCounts
        self.selectDateAction = selectDateAction
    }

    func makeUIView(context: Context) -> UICalendarView {
        let view = UICalendarView()
        view.calendar = self.calendar

        let calendarStartDate = DateComponents(calendar: self.calendar, year: 2007, month: 1, day: 1).date!
        let calendarViewDateRange = DateInterval(start: calendarStartDate, end: Date())
        view.availableDateRange = calendarViewDateRange

        view.selectionBehavior = UICalendarSelectionSingleDate(delegate: context.coordinator)
        view.delegate = context.coordinator

        return view
    }

    func updateUIView(_ uiView: UICalendarView, context: Context) {
        context.coordinator.stepCounts = stepCounts
        context.coordinator.dailyTargetSteps = dailyTargetSteps

        if !stepCounts.isEmpty {
            /*
             今現在の月のカレンダーを更新する。
             表示している月が現在の月でない可能性もあるが、その場合でも現在の月に対してreloadDecorationsを呼ぶことでその月の状態も更新される。
             「表示している月」に対してreloadDecorationsを呼ぶことがベストであるが、その情報は取得できなさそうなのでこのような対応をしている。
             */
            let now = Date()
            let startOfMonth = calendar.dateInterval(of: .month, for: now)!.start

            let thisMonthDateComponents: [DateComponents] = calendar.array(from: startOfMonth, to: now)
            uiView.reloadDecorations(forDateComponents: thisMonthDateComponents, animated: false)
        }
    }

    func makeCoordinator() -> Coordinator {
        Self.Coordinator(parent: self)
    }
}

public extension Calendar {
    func array(from startDate: Date, to endDate: Date) -> [DateComponents] {
        var result: [DateComponents] = []

        let diff = dateComponents([.day], from: startDate, to: endDate).day ?? 0
        print("diff: \(diff)")
        for day in 0...diff {
            let date = date(byAdding: .day, value: day, to: startDate)!
            let item = dateComponents(in: .current, from: date)
            result.append(item)
        }

        return result
    }
}

// MARK: Coordinator

extension CalendarView {
    final class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {

        private let parent: CalendarView
        private let calendar: Calendar = .current

        var stepCounts: [Date: StepCount] = [:]
        var dailyTargetSteps: Int = 0

        init(parent: CalendarView) {
            self.parent = parent
        }

        func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
            let date = dateComponents.date!
            if stepCounts.keys.contains(date) {
                let stepCount = stepCounts[date]!
                if stepCount.number >= dailyTargetSteps {
                    return .default(color: .red)
                } else {
                    return nil
                }
            } else {
                return nil
            }
        }

        func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
            if let date = dateComponents?.date {
                parent.selectDateAction(date)
            }
        }
    }
}
