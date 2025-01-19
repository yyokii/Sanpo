import Foundation
import Model
import SwiftUI

/// 単一の月をカレンダー表示するためのビュー
struct CalendarMonthView: View {
    private let yearMonth: YearMonth
    private let calendar: Calendar
    private let monthNameFormatter: DateFormatter
    private let days: [Day]
    private let stepCounts: [Date: StepCount]
    private let dateTappedAction: (Date) -> Void

    init(
        yearMonth: YearMonth,
        calendar: Calendar = .current,
        stepCounts: [Date: StepCount],
        dateTappedAction: @escaping (Date) -> Void
    ) {
        self.yearMonth = yearMonth
        self.calendar = calendar

        self.monthNameFormatter = {
            let df = DateFormatter()
            df.calendar = calendar
            df.locale = Locale.autoupdatingCurrent
            df.dateFormat = "MMMM yyyy"
            return df
        }()

        self.days = Day.makeForMonth(of: yearMonth, calendar: calendar)
        self.stepCounts = stepCounts
        self.dateTappedAction = dateTappedAction
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(monthTitle)
                .font(.headline)
                .accessibilityAddTraits(.isHeader)

            Spacer(minLength: 12).fixedSize()

            // 曜日ヘッダ行
            let weekdaySymbols = weekdaySymbolsForCurrentCalendar()
            HStack(alignment: .center, spacing: 0) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                        .accessibilityHidden(true)
                }
            }

            Spacer(minLength: 8).fixedSize()

            // 日付表示グリッド
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(minimum: 20), spacing: 4), count: 7), // 1行に表示するアイテムの設定
                spacing: 4 // vertical spacing
            ) {
                ForEach(days) { day in
                    Button {
                        dateTappedAction(day.date)
                    } label: {
                        VStack(alignment: .center, spacing: 4) {
                            Text("\(calendar.component(.day, from: day.date))")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(day.ignored ? .secondary : .primary)
                                .accessibilityHidden(day.ignored)
                            if let step = stepCounts[day.date], !day.ignored {
                                Text("\(step.number)")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(4)
                                    .background(
                                        Color.green.opacity(
                                            step.number <= 5000
                                            ? 0.2
                                            : step.number <= 10000 ? 0.5 : 1.0
                                        )
                                    )
                                    .cornerRadius(4)
                            }
                            Spacer()
                        }
                        .frame(height: 56)
                        .frame(maxWidth: .infinity)
                        .background(
                            day.ignored ? Color.clear : Color(.systemGray6)
                        )
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    /// 表示中の月のタイトル文字列を生成
    private var monthTitle: String {
        let components = DateComponents(year: yearMonth.year, month: yearMonth.month)
        guard let date = calendar.date(from: components) else {
            return "\(yearMonth.year)-\(yearMonth.month)"
        }
        return monthNameFormatter.string(from: date)
    }

    /// カレンダーに適合した曜日配列を取得
    /// CalendarでのfirstWeekdayを考慮して並び替え
    private func weekdaySymbolsForCurrentCalendar() -> [String] {
        let symbols = calendar.shortStandaloneWeekdaySymbols
        let firstWeekdayIndex = calendar.firstWeekday - 1
        return Array(symbols[firstWeekdayIndex...] + symbols[..<firstWeekdayIndex])
    }
}

/// 複数年分のカレンダーのリスト
struct CalendarListView: View {
    private let months: [YearMonth]
    private let calendar: Calendar
    private let stepCounts: [Date: StepCount]

    @State private var selectedDate: SelectedDate?

    init(
        stepCounts: [Date: StepCount],
        calendar: Calendar = .current,
        dateTappedAction: @escaping (Date) -> Void
    ) {
        self.calendar = calendar
        self.stepCounts = stepCounts

        let yearMonths = stepCounts.keys.compactMap { date -> YearMonth? in
            let components = calendar.dateComponents([.year, .month], from: date)
            guard let year = components.year, let month = components.month else { return nil }
            return YearMonth(year: year, month: month)
        }

        if let start = yearMonths.min(), let end = yearMonths.max() {
            self.months = Array(MonthRange(start: start, end: end)).reversed()
        } else {
            self.months = []
        }
    }

    var body: some View {
        List {
            ForEach(months, id: \.self) { month in
                Section {
                    CalendarMonthView(
                        yearMonth: month,
                        calendar: calendar,
                        stepCounts: stepCounts,
                        dateTappedAction:  { date in
                            selectedDate = .init(date: date)
                        }
                    )
                }
            }
        }
        .listStyle(.plain)
        // TODO: 特定の日のデータ表示
//        .sheet(item: $selectedDate) { date in
//            
//        }
    }
}

struct SelectedDate: Identifiable {
    let date: Date
    var id: Date { date }
}

#Preview {
    let mockStepCounts: [Date: StepCount] = {
        let calendar = Calendar.current
        var data: [Date: StepCount] = [:]

        if let startDate = calendar.date(from: DateComponents(year: 2024, month: 11, day: 1)) {
            for dayOffset in 0..<90 {
                if let date = calendar.date(byAdding: .day, value: dayOffset, to: startDate) {
                    data[date] = .init(start: date, end: date, number: Int.random(in: 1000...15000))
                }
            }
        }

        return data
    }()

    NavigationStack {
        CalendarListView(
            stepCounts: mockStepCounts,
            dateTappedAction: { date in
                print("\(date) tapped")
            }
        )
    }
}
