import StyleGuide
import SwiftUI

public struct TitleChip: View {
    let title: String

    public init(_ title: String) {
        self.title = title
    }

    public var body: some View {
        Text(title)
            .font(.xSmall)
            .bold()
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(.black)
            .clipShape(.rect(cornerRadius: 12))
    }
}
