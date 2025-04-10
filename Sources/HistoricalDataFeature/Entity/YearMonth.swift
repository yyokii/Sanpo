import Foundation

/// 年と月を表す構造体（例: 2023年5月）。
/// カレンダーの表示範囲を指定する際などに利用する。
public struct YearMonth: Hashable, Comparable {
    public let year: Int
    public let month: Int // 1-based (January = 1, December = 12)

    public init(year: Int, month: Int) {
        precondition(month >= 1 && month <= 12, "月は1〜12の範囲で指定してください")
        self.year = year
        self.month = month
    }

    public static func < (lhs: YearMonth, rhs: YearMonth) -> Bool {
        if lhs.year == rhs.year {
            return lhs.month < rhs.month
        }
        return lhs.year < rhs.year
    }

    /// 現在のYearMonthに指定した月数を加算・減算し、新たなYearMonthを返す
    public func addingMonths(_ monthsToAdd: Int) -> YearMonth {
        // 通算月数
        let updatedTotalMonths = year * 12 + month + monthsToAdd
        // 通算月数を年と月に変換
        let newYear = updatedTotalMonths / 12
        let newMonth = updatedTotalMonths % 12
        // 月が0の場合は前年の12月に調整
        let adjustedYear = newMonth == 0 ? newYear - 1 : newYear
        let adjustedMonth = newMonth == 0 ? 12 : newMonth
        return YearMonth(year: adjustedYear, month: adjustedMonth)
    }
}

/// 年月範囲を指定して、その中のYearMonthを順次列挙するシーケンス
public struct MonthRange: Sequence, IteratorProtocol {
    private let end: YearMonth
    private var current: YearMonth

    public init(start: YearMonth, end: YearMonth) {
        precondition(start <= end, "開始年月は終了年月よりも前である必要があります")
        self.current = start
        self.end = end
    }

    /// 現在の年月を返し、現在の年月を1月進める
    public mutating func next() -> YearMonth? {
        guard current <= end else { return nil }
        let result = current
        current = current.addingMonths(1)
        return result
    }
}

/// カレンダー表示用の日付情報を表す構造体
/// 特定の月に該当する日付および前後月の余白日付を生成する機能を持つ。
struct Day: Identifiable {
    var id: UUID = .init()
    var date: Date
    /// 当月以外の日付（前月または翌月の余白）であればtrue
    var ignored: Bool = false

    /// 指定した年月のカレンダー用日付一覧を生成する
    ///
    /// - Parameters:
    ///   - yearMonth: 対象の年月
    ///   - calendar: 利用するカレンダー。指定しなければ現在カレンダー
    /// - Returns: 対象月のカレンダー表示用日付配列
    static func makeForMonth(
        of yearMonth: YearMonth,
        calendar: Calendar = .current
    ) -> [Day] {
        var days: [Day] = []

        // 年月から月初のDateを取得
        guard let startOfMonth = calendar.date(from: DateComponents(year: yearMonth.year, month: yearMonth.month)),
              let daysInMonth = calendar.range(of: .day, in: .month, for: startOfMonth)?.count else {
            return days
        }

        // 当月初日
        let firstDay = startOfMonth
        // 当月最終日
        guard let lastDay = calendar.date(byAdding: .day, value: daysInMonth - 1, to: firstDay) else {
            return days
        }

        // 月初の曜日
        let firstWeekDay = calendar.component(.weekday, from: firstDay)
        // 月初の曜日に応じて必要な前月余白日数を求める（1始まり）
        let startIgnoredCount = max(firstWeekDay - 1, 0)

        // 前月余白日の生成
        for i in (0..<startIgnoredCount).reversed() {
            guard let prevDate = calendar.date(byAdding: .day, value: -(i + 1), to: firstDay) else {
                continue
            }
            days.append(Day(date: prevDate, ignored: true))
        }

        // 当月日付の生成
        for dayOffset in 0..<daysInMonth {
            guard let currentDate = calendar.date(byAdding: .day, value: dayOffset, to: firstDay) else {
                continue
            }
            days.append(Day(date: currentDate, ignored: false))
        }

        // 月末の曜日
        let lastWeekDay = calendar.component(.weekday, from: lastDay)
        // 翌月余白日数を求める
        let endIgnoredCount = 7 - lastWeekDay

        // 翌月余白日の生成
        for i in 0..<endIgnoredCount {
            guard let nextDate = calendar.date(byAdding: .day, value: i + 1, to: lastDay) else {
                continue
            }
            days.append(Day(date: nextDate, ignored: true))
        }

        return days
    }
}
