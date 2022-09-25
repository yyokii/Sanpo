import SwiftUI

import Constant
import Extension
import Model

public struct HomeView: View {
    @AppStorage(
        UserDefaultsKey.dailyTargetSteps.rawValue,
        store: UserDefaults.app
    )
    var dailyTargetSteps: Int = 0

    @StateObject var todayStepCountStore = TodayStepCountStore()

    @State private var inputGoal = 0

    public init() {}

    public var body: some View {
        VStack(spacing: 8) {
            Text("Home View")

            Text("my goal is \(dailyTargetSteps)")
            TextField("Set Goal", value: $inputGoal, formatter: NumberFormatter())
            Button {
                dailyTargetSteps = inputGoal
            } label: {
                Text("Save")
            }

            switch todayStepCountStore.phase {
            case .waiting:
                Text("waiting")
            case .success:
                Text("success")
                Text("\(todayStepCountStore.todayStepCount!.number)")
                if todayStepCountStore.todayStepCount!.number >= dailyTargetSteps {
                    Text("Goal is achieved")
                } else {
                    Text("Goal is not achieved")
                }
            case .failure(let error):
                Text("failure \(error.debugDescription)")
            }
        }
        .padding()
        .onAppear {
            inputGoal = dailyTargetSteps
        }
    }
}

#if DEBUG

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

#endif
