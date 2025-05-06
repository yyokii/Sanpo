import Constant
import Foundation
import SwiftUI

struct SelectCardImageView: View {
    @AppStorage(UserDefaultsKey.cardBackgroundImageName.rawValue) private var selectedCardImage = ""

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            TodayDataCard(
                stepCount: .random(in: 100...9000),
                yesterdayStepCount: .random(in: 100...9000),
                distance: .random(in: 1000...9000),
                backgroundImageName: selectedCardImage
            )
            .animation(.easeInOut, value: selectedCardImage)
            .padding(.horizontal, 16)

            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(CardImage.allCases, id: \ .self) { cardImage in
                        Button {
                            selectedCardImage = cardImage.fileName
                        } label: {
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: .init(named: cardImage.fileName, in: .module, with: .none) ?? UIImage())
                                    .resizable()
                                    .cornerRadius(8)

                                if selectedCardImage == cardImage.fileName {
                                    Image(systemName: "checkmark.circle.fill")
                                        .resizable()
                                        .foregroundColor(.green)
                                        .frame(width: 30, height: 30)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 8)
                                }
                            }
                            .aspectRatio(16/9, contentMode: .fit)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle(String(localized: "select-background-image-title", bundle: .module))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SelectCardImageView()
    }
}

