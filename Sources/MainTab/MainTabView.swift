import SwiftUI

import HistoricalDataFeature
import HomeFeature
import Model

public struct MainTabView: View {
    @StateObject var weatherData = WeatherData()
    @State var selectedTab: TabItem = .home

    public init() {}

    public var body: some View {
        ZStack(alignment: .bottom) {
            switch selectedTab {
            case .home:
                NavigationStack {
                    HomeView()
                }
                .transition(.move(edge: .leading))
            case .myPage:
                NavigationStack {
                    HistoricalDataView()
                }
                .transition(.move(edge: .trailing))
            }

            SegmentedTabItemView(selectedItem: $selectedTab)
                .padding(.bottom, 12)
        }
        .environmentObject(weatherData)
    }
}

extension MainTabView {
    func tabItem(of item: TabItem) -> some View {
        let isSelected = selectedTab == item
        return Button {
            withAnimation {
                selectedTab = item
            }
        } label: {
            HStack(alignment: .center, spacing: 4) {
                Image(systemName: item.iconName)
                    .font(.system(size: 16))
                    .foregroundStyle( isSelected ? .black : .gray)
                Text(item.title)
                    .font(.system(size: 18))
                    .foregroundStyle( isSelected ? .black : .gray)
            }
            .bold()
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .background(Capsule().fill(isSelected ? .white : .clear))
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
