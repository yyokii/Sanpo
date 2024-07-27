import SwiftUI

import HistoricalDataFeature
import HomeFeature
import Model

public struct MainTabView: View {
    @StateObject var weatherData = WeatherData()

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
        .environmentObject(weatherData)
        .tint(.black)
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
