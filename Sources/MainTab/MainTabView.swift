import SwiftUI

import HistoricalDataFeature
import HomeFeature

public struct MainTabView: View {
    enum TabItem {
        case home
        case historicalData
    }
    @State var selectedItem: TabItem = .home

    public init() {}

    public var body: some View {
        TabView(selection: $selectedItem) {
            NavigationView {
                HomeView()
            }
            .tabItem {
                Image(systemName: "person.crop.circle")
                Text("Home")

            }
            .tag(TabItem.home)

            HistoricalDataView()
                .tabItem {
                    Image(systemName: "clock")
                    Text("Data")

                }
                .tag(TabItem.historicalData)
        }
    }
}

#if DEBUG

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {

        Group {
            MainTabView()
                .environment(\.colorScheme, .light)

            MainTabView()
                .environment(\.colorScheme, .dark)
        }
    }
}

#endif
