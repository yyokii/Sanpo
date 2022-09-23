import SwiftUI

import Model

public struct HomeView: View {
    @EnvironmentObject var stepCountStore: StepCountStore
    @StateObject var demo = DemoStore()

    public init() {}

    public var body: some View {
        VStack {
            Text("Home View")

            switch stepCountStore.phase {
            case .waiting:
                Text("waiting")
            case .success:
                Text("success")
                Text("\(stepCountStore.todayStepCount!.number)")
            case .failure(let error):
                Text("failure \(error.debugDescription)")
            }
        }
        .padding()
    }
}

#if DEBUG

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

#endif
