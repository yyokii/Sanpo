import SwiftUI

struct ProgressIndicatorView: View {
    @State private var isAnimating = false

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { index in
                Circle()
                    .frame(width: 10, height: 10)
                    .foregroundColor(.black)
                    .scaleEffect(isAnimating ? 0.5 : 1)
                    .animation(
                        .easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            self.isAnimating = true
        }
        .padding()
    }
}

#Preview {
    ProgressIndicatorView()
}
