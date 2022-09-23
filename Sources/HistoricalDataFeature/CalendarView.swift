import SwiftUI

import Model

struct CalendarView: UIViewRepresentable {
    let stepCounts: [StepCount]
    let myGoal: MyGoalStore
    let selectDateAction: (Date) -> Void

    init(
        stepCounts: [StepCount],
        myGoal: MyGoalStore,
        selectDateAction: @escaping (Date) -> Void
    ) {
        self.stepCounts = stepCounts
        self.myGoal = myGoal
        self.selectDateAction = selectDateAction
    }

    func makeUIView(context: Context) -> some UIView {
        let view = UICalendarView()
        view.calendar = Calendar(identifier: .gregorian)

        let fromDate = DateComponents(calendar: Calendar(identifier: .gregorian), year: 1900, month: 1, day: 1).date!
        let toDate = Date()
        let calendarViewDateRange = DateInterval(start: fromDate, end: toDate)
        view.availableDateRange = calendarViewDateRange

        view.selectionBehavior = UICalendarSelectionSingleDate(delegate: context.coordinator)
        view.delegate = context.coordinator

        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Self.Coordinator(parent: self)
    }
}


// MARK: Coordinator

extension CalendarView {
    final class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {

        private let parent: CalendarView

        init(parent: CalendarView) {
            self.parent = parent
        }

        func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {

            return nil
        }

        func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
            if let date = dateComponents?.date {
                parent.selectDateAction(date)
            }
        }
    }
}
