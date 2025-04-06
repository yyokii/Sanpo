import SwiftUI
import StyleGuide

public struct CardView<Content: View>: View {
    let content: () -> Content
    
    public init(
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.content = content
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background {
            Rectangle()
                .fill(.white)
                .clipShape(.rect(cornerRadius: 20))
                .adaptiveShadow()
        }
    }
}
