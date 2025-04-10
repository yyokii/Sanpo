import Combine
import SwiftUI

struct CountdownView: View {
    @State private var timeRemaining = 5
    @State private var scale: CGFloat = 1.0
    @State private var opacity: CGFloat = 0

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        Text("\(timeRemaining)")
            .font(.system(size: 100))
            .scaleEffect(scale)
            .opacity(opacity)
            .onReceive(timer) { _ in
                if timeRemaining > 0 {
                    withAnimation(.bouncy(duration: 0.3)) {
                        scale = 3
                        opacity = 1
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        scale = 1
                        opacity = 0.0
                        timeRemaining -= 1
                    }
                    if timeRemaining == 0 {
                        timer.upstream.connect().cancel()
                    }
                }
            }
    }
}

#Preview {
    CountdownView()
}
