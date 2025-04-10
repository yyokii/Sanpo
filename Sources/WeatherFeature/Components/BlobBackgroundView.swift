import SwiftUI

struct BlobBackgroundView: View {
    @State private var animate = false

    var body: some View {
        ZStack(alignment: .top) {
            // 画面いっぱいに広げる（背景用）
            Color.clear
                .ignoresSafeArea()

            // 何個か重ねてぼかし円を描く
            ForEach(0..<3) { index in
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hue: Double(index) * 0.2, saturation: 0.8, brightness: 1.0),
                                Color(hue: Double(index) * 0.2 + 0.1, saturation: 0.8, brightness: 1.0)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blur(radius: 120)
                    .frame(width: 200)
                    // Viewの上部でランダムに動かす
                    .offset(
                        x: animate ? CGFloat.random(in: -200...200) : CGFloat.random(in: -200...200),
                        y: animate ? CGFloat.random(in: -100...200) : CGFloat.random(in: -100...200)
                    )
                    .animation(
                        .easeInOut(duration: 8)
                        .repeatForever(autoreverses: true),
                        value: animate
                    )
            }
        }
        .onAppear {
            // 画面表示後にアニメーション開始
            animate = true
        }
    }
}

#Preview {
    BlobBackgroundView()
}
