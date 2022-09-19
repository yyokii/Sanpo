import SwiftUI
import Combine

public struct HomeView: View {
    @StateObject var homeVM: HomeVM

    public init(homeVM: HomeVM = HomeVM()) {
        self._homeVM = StateObject(wrappedValue: homeVM)
    }

    public var body: some View {
        VStack {
            Text("Home View")
        }
        .padding()
    }
}

#if DEBUG

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(homeVM: HomeVM())
    }
}

#endif
