import SwiftUI

struct CardView<Content: View>: View {
    let content: () -> Content
    
    init(
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content()
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 12)
        .padding(.bottom, 12)
        .background {
            Rectangle()
                .fill(Color.adaptiveWhite)
                .cornerRadius(20)
                .adaptiveShadow()
        }
    }
}
