import SwiftUI

struct GoalView: View {
    let title: String
    let value: Int
    let unitText: String
    let goal: Int

    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center, spacing: 0) {
                    Text(title)
                        .adaptiveFont(.bold, size: 12)
                    Spacer()
                    Button {

                    } label: {
                        Image(systemName: "square.and.pencil")
                            .foregroundStyle(Color.adaptiveBlack)
                    }
                }
                Text("\(value)/\(goal)\(unitText)")
                    .adaptiveFont(.normal, size: 12)
            }

            CircularProgressBar(progress: (CGFloat(value) / CGFloat(goal)))
                .padding(.horizontal, 16)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .background {
            Rectangle()
                .fill(Color.adaptiveWhite)
                .cornerRadius(20)
                .adaptiveShadow()
        }
    }
}

struct EditGoalButton: View {
    var body: some View {
        Button {

        } label: {
            VStack {
                Image(systemName: "square.and.pencil")
                Text("目標を設定")
            }
            .frame(width: 120, height: 120)
            .background {
                Rectangle()
                    .fill(Color.adaptiveWhite)
                    .cornerRadius(20)
                    .adaptiveShadow()
            }
        }
    }
}

#if DEBUG

#Preview {
    GoalView(title: "demo", value: 1000, unitText: "歩", goal: 2000)
        .frame(width: 200, height: 200)
}

#Preview {
    EditGoalButton()
}

#endif
