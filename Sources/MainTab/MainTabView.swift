import HomeFeature
import Model
import SwiftUI
import WeatherFeature

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
                WeatherDataView()
            }
            .tabItem {
                Image(systemName: "sun.horizon")
                Text("Weather")
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
