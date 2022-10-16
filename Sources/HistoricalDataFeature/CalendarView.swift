import SwiftUI

import Constant
import Model

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

        let calendarStartDate = DateComponents(calendar: self.calendar, year: 2014, month: 9, day: 1).date!
        let calendarViewDateRange = DateInterval(start: calendarStartDate, end: Date())
        view.availableDateRange = calendarViewDateRange

        let dateSelection = UICalendarSelectionSingleDate(delegate: context.coordinator)
        view.selectionBehavior = dateSelection
        view.delegate = context.coordinator

        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        dateSelection.setSelected(Calendar.current.dateComponents(in: .current, from: yesterday), animated: false)

        return view
    }

    func updateUIView(_ uiView: UICalendarView, context: Context) {
        context.coordinator.stepCounts = stepCounts
        context.coordinator.dailyTargetSteps = dailyTargetSteps
    }

    func makeCoordinator() -> Coordinator {
        Self.Coordinator(parent: self)
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

        func calendarView(
            _ calendarView: UICalendarView,
            decorationFor dateComponents: DateComponents
        ) -> UICalendarView.Decoration? {
            let date = dateComponents.date!
            if stepCounts.keys.contains(date) {
                let stepCount = stepCounts[date]!
                return .customView {
                    let label = UILabel()
                    label.text = "\(stepCount.number)"

                    let color = UIColor(Color.appMain)
                    if stepCount.number >= 10000 {
                        label.textColor = color
                    } else if stepCount.number >= 5000 {
                        label.textColor = color.withAlphaComponent(0.8)
                    } else if stepCount.number >= 2500 {
                        label.textColor = color.withAlphaComponent(0.6)
                    } else {
                        label.textColor = color.withAlphaComponent(0.4)
                    }
                    return label
                }
            } else {
                return nil
            }
        }

        func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
            print("📝 didSelectDate")
            if let date = dateComponents?.date {
                parent.selectDateAction(date)
            }
        }
    }
}
