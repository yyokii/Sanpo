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

    init(yearMonth: YearMonth, calendar: Calendar = .current, stepCounts: [Date: StepCount]) {
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
                columns: Array(repeating: GridItem(.flexible(minimum: 20), spacing: 0), count: 7), // 1行に表示するアイテムの設定
                spacing: 0 // vertical spacing
            ) {
                ForEach(days) { day in
                    VStack(alignment: .center, spacing: 4) {
                        Text("\(calendar.component(.day, from: day.date))")
                            .font(.body)
                            .foregroundColor(day.ignored ? .secondary : .primary)
                            .accessibilityHidden(day.ignored)
                        if let step = stepCounts[day.date], !day.ignored {
                            Text("\(step.number)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .frame(height: 50)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
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

/// 複数年分のカレンダーを連続してリスト表示するビュー
/// 指定した年月範囲でスクロール表示させることができる。
struct MultiYearCalendarListView: View {
    private let months: [YearMonth]
    private let calendar: Calendar
    private let stepCounts: [Date: StepCount]

    init(
        start: YearMonth,
        end: YearMonth,
        calendar: Calendar = .current,
        stepCounts: [Date: StepCount]
    ) {
        self.calendar = calendar
        self.months = Array(MonthRange(start: start, end: end)).reversed()
        self.stepCounts = stepCounts
    }

    var body: some View {
        List {
            ForEach(months, id: \.self) { month in
                Section {
                    CalendarMonthView(yearMonth: month, calendar: calendar, stepCounts: stepCounts)
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("カレンダー")
    }
}

#Preview {
    let mockStepCounts: [Date: StepCount] = {
        let calendar = Calendar.current
        var data: [Date: StepCount] = [:]

        if let startDate = calendar.date(from: DateComponents(year: 2024, month: 11, day: 1)) {
            for dayOffset in 0..<30 {
                if let date = calendar.date(byAdding: .day, value: dayOffset, to: startDate) {
                    data[date] = .init(start: date, end: date, number: Int.random(in: 1000...15000))
                }
            }
        }

        return data
    }()

    NavigationStack {
        MultiYearCalendarListView(
            start: YearMonth(year: 2022, month: 1),
            end: YearMonth(year: 2024, month: 12),
            stepCounts: mockStepCounts
        )
    }
}
