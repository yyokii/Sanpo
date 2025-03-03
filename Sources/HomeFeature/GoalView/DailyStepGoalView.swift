import SwiftUI

/*
 前日達成している場合: 先日は目標達成しました。
 "Great job on meeting your goal yesterday! Keep up the amazing work!"
 "You crushed it yesterday—let’s keep that momentum going today!"
 "Yesterday’s achievement was fantastic. Carry that energy into today!"

 2日以上達成している場合: ~日連続で達成しています。

 連続達成しておらず前日も未達成の場合: 今月は~日目標を達成しています。


 */

struct DailyStepGoalView: View {
    let todaySteps: Int
    let goal: Int

    var body: some View {
        CardView {
            HStack(alignment: .center, spacing: 0) {
                VStack(alignment: .center, spacing: 0) {
                    Text(makeAttributedString(
                        fullText: "goal streak \(10) days",
                        highlightedSubstring: "goal streak \(10) days"))
                    Spacer(minLength: 8).fixedSize()
                    Text("Goal: \(goal)steps")
                        .foregroundStyle(.black)
                        .adaptiveFont(.normal, size: 12)
                }
                Spacer(minLength: 20)
                CircularProgressBar(progress: (CGFloat(todaySteps) / CGFloat(goal)))
                    .frame(width: 120)

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

#if DEBUG

#Preview {
    DailyStepGoalView(todaySteps: 1000, goal: 2000)
        .padding(.horizontal, 24)
}

#endif
