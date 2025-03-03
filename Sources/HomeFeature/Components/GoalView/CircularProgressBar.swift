import SwiftUI

struct CircularProgressBar: View {
    let progress: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 12.0)
                .opacity(0.3)
                .foregroundColor(.gray)

            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(
                    .black,
                    style: .init(lineWidth: 12, lineCap: .round, lineJoin: .round)
                )
                .foregroundColor(.blue)
                .rotationEffect(.degrees(-90))
                .animation(.spring, value: progress)

            HStack(alignment: .bottom, spacing: 2) {
                Text(String(format: "%.0f", progress * 100.0))
                    .adaptiveFont(.bold, size: 30)
                Text("%")
                    .adaptiveFont(.bold, size: 20)
            }
        }
        .padding(8) // CircleのstrokeのwidthによりViewの表示領域外にも少しはみ出すので、表示領域に収まるように設定
    }
}

#if DEBUG

struct CircularProgressBarPreview: View {
    @State var progress: CGFloat = 0.3

    var body: some View {
        VStack {
            CircularProgressBar(progress: progress)
                .frame(width: 150.0, height: 150.0)
                .padding(32.0)

            Slider(value: $progress, in: 0.0...1.5)
        }
    }
}

#Preview {
    CircularProgressBarPreview()
}

#endif
