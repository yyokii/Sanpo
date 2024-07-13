import SwiftUI

struct SegmentedTabItemView: View {
    @Namespace private var namespace
    @Binding var selectedItem: TabItem

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            ForEach(TabItem.allCases) { item in
                Button {
                    withAnimation {
                        selectedItem = item
                    }
                } label: {
                    HStack(alignment: .center, spacing: 4) {
                        Image(systemName: item.iconName)
                            .font(.system(size: 16))
                            .foregroundStyle( selectedItem == item ? .black : .gray)
                        Text(item.title)
                            .font(.system(size: 18))
                            .foregroundStyle( selectedItem == item ? .black : .gray)
                    }
                    .bold()
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                }
                .matchedGeometryEffect(id: item.id, in: namespace, isSource: true)
            }
        }
        .background(
            Capsule()
                .foregroundStyle(.white)
                .matchedGeometryEffect(
                    id: selectedItem.id,
                    in: namespace,
                    isSource: false
                ) // 遷移元/先となるのは各ボタンであるのでisSourceはfalseにする
        )
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
        .background(.thinMaterial, in: Capsule())
    }
}

#Preview {
    struct PreviewSegmentedTabItemView: View {
        @State private var selectedItem: TabItem = .home

        var body: some View {
            SegmentedTabItemView(selectedItem: $selectedItem)
        }
    }

    return PreviewSegmentedTabItemView()
}
