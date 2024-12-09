import Foundation
import SwiftUI

/// 単一の月をカレンダー表示するためのビュー
struct CalendarMonthView: View {
    private let yearMonth: YearMonth
    private let calendar: Calendar
    private let monthNameFormatter: DateFormatter
    private let days: [Day]

    init(yearMonth: YearMonth, calendar: Calendar = .current) {
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
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(monthTitle)
                .font(.headline)
                .accessibilityAddTraits(.isHeader)

            // 曜日ヘッダ行
            let weekdaySymbols = weekdaySymbolsForCurrentCalendar()
            HStack {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                        .accessibilityHidden(true)
                }
            }

            // 日付表示グリッド
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 20), spacing: 4), count: 7), spacing: 4) {
                ForEach(days) { day in
                    Text("\(calendar.component(.day, from: day.date))")
                        .font(.body)
                        .foregroundColor(day.ignored ? .secondary : .primary)
                        .frame(minWidth: 20, minHeight: 20)
                        .accessibilityHidden(day.ignored)
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

    init(start: YearMonth, end: YearMonth, calendar: Calendar = .current) {
        self.calendar = calendar
        self.months = Array(MonthRange(start: start, end: end)).reversed()
    }

    var body: some View {
        List {
            ForEach(months, id: \.self) { month in
                Section {
                    CalendarMonthView(yearMonth: month, calendar: calendar)
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("カレンダー")
    }
}

#Preview {
    NavigationStack {
        MultiYearCalendarListView(
            start: YearMonth(year: 2022, month: 1),
            end: YearMonth(year: 2024, month: 12)
        )
    }
}
