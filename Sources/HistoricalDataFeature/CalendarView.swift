import SwiftUI

import Model

struct CalendarView: UIViewRepresentable {
    let stepCounts: [Date: StepCount]
    let myGoal: MyGoalStore
    let selectDateAction: (Date) -> Void

    init(
        stepCounts: [Date: StepCount],
        myGoal: MyGoalStore,
        selectDateAction: @escaping (Date) -> Void
    ) {
        self.stepCounts = stepCounts
        self.myGoal = myGoal
        self.selectDateAction = selectDateAction
    }

    func makeUIView(context: Context) -> UICalendarView {
        let view = UICalendarView()
        view.calendar = Calendar.current

        let fromDate = DateComponents(calendar: Calendar.current, year: 2007, month: 1, day: 1).date!
        let toDate = Date()
        let calendarViewDateRange = DateInterval(start: fromDate, end: toDate)
        view.availableDateRange = calendarViewDateRange

        view.selectionBehavior = UICalendarSelectionSingleDate(delegate: context.coordinator)
        view.delegate = context.coordinator

        return view
    }

    func updateUIView(_ uiView: UICalendarView, context: Context) {
        context.coordinator.stepCounts = stepCounts
//        uiView.reloadDecorations(forDateComponents: [DateComponents(calendar: Calendar.current, year: 2022, month: 9, day: 8)], animated: true)
    }

    func makeCoordinator() -> Coordinator {
        Self.Coordinator(parent: self)
    }
}

// MARK: Coordinator

extension CalendarView {
    final class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {

        private let parent: CalendarView

        var stepCounts: [Date: StepCount] = [:]

        private let calendar: Calendar = .current

        init(parent: CalendarView) {
            self.parent = parent
        }

        func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
            let date = dateComponents.date!
            if stepCounts.keys.contains(date) {
                let stepCount = stepCounts[date]!
                if stepCount.number >= 3000 {
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
