import Components
import Model
import SwiftUI

struct AdviceCard: View {

    let analysis: StepCountAnalysis

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 4) {
                TitleChip("Trend")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(analysis.trend)
                    .font(.small)
                    .padding(.horizontal, 4)
            }

            Spacer(minLength: 16).fixedSize()

            VStack(alignment: .leading, spacing: 4) {
                TitleChip("Advice")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(analysis.advice)
                    .font(.small)
                    .padding(.horizontal, 4)
            }
        }
    }
}

#Preview {
    AdviceCard(
        analysis: .init(
            trend: "loreum ipsum loreum ipsum loreum ipsum loreum ipsum loreum ipsum",
            advice: "loreum ipsum loreum ipsum loreum ipsum loreum ipsum loreum ipsumloreum ipsum loreum ipsum loreum ipsum loreum ipsum loreum ipsum"
        )
    )
}
