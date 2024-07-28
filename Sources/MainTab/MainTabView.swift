import SwiftUI

import HistoricalDataFeature
import HomeFeature
import Model

public struct MainTabView: View {
    public init() {}

    public var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Image(systemName: "figure.walk")
                Text("Sanpo")
            }

            NavigationStack {
                HistoricalDataView()
            }
            .tabItem {
                Image(systemName: "calendar.badge.clock")
                Text("Data")
            }
        }
        .tint(.black)
    }
}

// クラッシュするのでコメントアウト
//#if DEBUG
//
//struct MainTabView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainTabView()
//            .environmentObject(WeatherData())
//    }
//}
//
//#endif
