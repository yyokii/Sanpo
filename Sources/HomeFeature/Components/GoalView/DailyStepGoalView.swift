import Components
import SwiftUI

struct DailyStepGoalView: View {
    let todaySteps: Int
    let goal: Int
    let goalAchievementStatus: GoalAchievementStatus

    var body: some View {
        CardView {
            HStack(alignment: .center, spacing: 0) {
                VStack(alignment: .center, spacing: 0) {
                    Text(goalAchievementStatus.message)
                    Spacer(minLength: 8).fixedSize()
                    Text("Goal: \(goal)steps")
                        .foregroundStyle(.black)
                        .adaptiveFont(.normal, size: 12)
                }
                Spacer(minLength: 30)
                CircularProgressBar(progress: (CGFloat(todaySteps) / CGFloat(goal)))
                    .frame(width: 100)

            }
        }
    }

    func makeAttributedString(
        fullText: String,
        highlightedSubstring: String
    ) -> AttributedString {
        var attributedString = AttributedString(fullText)
        attributedString.foregroundColor = .gray
        attributedString.font = .system(size: 14)
        if let range = attributedString.range(of: highlightedSubstring) {
            attributedString[range].foregroundColor = .black
            attributedString[range].font = .system(size: 20, weight: .bold)
        }
        return attributedString
    }
}

extension DailyStepGoalView {
    enum GoalAchievementStatus {
        /// 今日達成している場合
        case achievedToday(days: Int)
        /// 今日は未達且つ、2日以上連続で達成している場合
        case consecutive(days: Int)
        /// 今日は未達且つ、前日だけ達成している場合
        case achievedYesterday
        /// 今日は未達且つ、前日未達成の場合
        case missedYesterday

        init(isTodayAchieved: Bool, consecutiveDays: Int) {
            if isTodayAchieved {
                // 今日達成している場合は、昨日までの連続日数に今日分を加えてカウント
                self = .achievedToday(days: consecutiveDays + 1)
            } else {
                // 今日未達の場合は、昨日までの連続日数に基づいて分岐
                if consecutiveDays >= 2 {
                    self = .consecutive(days: consecutiveDays)
                } else if consecutiveDays == 1 {
                    self = .achievedYesterday
                } else {
                    self = .missedYesterday
                }
            }
        }

        var message: AttributedString {
            switch self {
            case let .achievedToday(days):
                if days > 1 {
                    let daysText = days > 99 ? "+99" : "\(days)"
                    return makeAttributedString(
                        fullText: String(localized: "achieved today \(daysText)", bundle: .module),
                        highlightedSubstring: String(localized: "fire \(daysText) days", bundle: .module)
                    )
                } else {
                    return makeAttributedString(
                        fullText: String(localized: "achieved today", bundle: .module),
                        highlightedSubstring: String(localized: "awesome job today", bundle: .module)
                    )
                }
            case let .consecutive(days):
                let daysText = days > 99 ? "+99" : "\(days)"
                return makeAttributedString(
                    fullText: String(localized: "goal streak \(daysText) days", bundle: .module),
                    highlightedSubstring: String(localized: "fire \(daysText) days", bundle: .module)
                )
            case .achievedYesterday:
                return makeAttributedString(
                    fullText: String(localized: "achieved yesterday", bundle: .module),
                    highlightedSubstring: String(localized: "great job yesterday", bundle: .module)
                )
            case .missedYesterday:
                return makeAttributedString(
                    fullText: String(localized: "missed yesterday", bundle: .module),
                    highlightedSubstring: "tomorrow is a fresh new start"
                )
            }
        }

        func makeAttributedString(
            fullText: String,
            highlightedSubstring: String
        ) -> AttributedString {
            var attributedString = AttributedString(fullText)
            attributedString.foregroundColor = .gray
            attributedString.font = .system(size: 14)
            if let range = attributedString.range(of: highlightedSubstring) {
                attributedString[range].foregroundColor = .black
                attributedString[range].font = .system(size: 20, weight: .bold)
            }
            return attributedString
        }
    }
}

#if DEBUG

#Preview {
    ScrollView {
        VStack(alignment: .center, spacing: 24) {
            DailyStepGoalView(todaySteps: 20000, goal: 2000, goalAchievementStatus: .achievedToday(days: 1))

            DailyStepGoalView(todaySteps: 2000, goal: 2000, goalAchievementStatus: .achievedToday(days: 1))

            DailyStepGoalView(todaySteps: 1000, goal: 2000, goalAchievementStatus: .achievedToday(days: 199))

            DailyStepGoalView(todaySteps: 1000, goal: 2000, goalAchievementStatus: .consecutive(days: 199))

            DailyStepGoalView(todaySteps: 1000, goal: 2000, goalAchievementStatus: .achievedYesterday)

            DailyStepGoalView(todaySteps: 1000, goal: 2000, goalAchievementStatus: .missedYesterday)
        }
        .padding(.horizontal, 24)
    }
}

#endif
