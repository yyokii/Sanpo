import SwiftUI

import HomeFeature

public struct MainTabView: View {
    enum TabItem {
        case home
        case calendar
    }
    @State var selectedItem: TabItem = .home

    public init() {}

    public var body: some View {
        TabView(selection: $selectedItem) {
            HomeView()
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Home")

                }
                .tag(TabItem.home)
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
