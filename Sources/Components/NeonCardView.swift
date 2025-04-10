import SwiftUI

extension View {
    func innerShadow<S: Shape>(
        using shape: S,
        angle: Angle = .degrees(0),
        color: Color,
        width: CGFloat,
        blur: CGFloat
    ) -> some View {
        return self
            .overlay(
                shape
                    .stroke(color, lineWidth: width)
                    .blur(radius: blur)
                    .mask(shape) // maskをかけることで内側の影を作っている
            )
    }

    func multicolorGlowAnimated(
        phase1: Angle,
        phase2: Angle,
        blur1: CGFloat,
        blur2: CGFloat
    ) -> some View {
        self.overlay(
            GeometryReader { geo in
                let size = geo.size
                ZStack {
                    Rectangle()
                        .fill(
                            AngularGradient(
                                gradient: Gradient(colors: [.purple, .green, .orange, .purple]),
                                center: .center,
                                angle: phase1
                            )
                        )
                        .frame(width: size.width + 100, height: size.height + 100)
                        .position(x: size.width / 2, y: size.height / 2)
                        .mask(self.blur(radius: blur1))
                        .overlay(self.blur(radius: 5))
                    Rectangle()
                        .fill(
                            AngularGradient(
                                gradient: Gradient(colors: [.red, .yellow, .green, .blue, .purple, .red]),
                                center: .center,
                                angle: phase2
                            )
                        )
                        .frame(width: size.width + 100, height: size.height + 100)
                        .position(x: size.width / 2, y: size.height / 2)
                        .mask(self.blur(radius: blur2))
                        .overlay(self)
                }
            },
            alignment: .center
        )
    }
}


struct NeonCardView4: View {
    @State private var phase1 = Angle(degrees: 0)
    @State private var phase2 = Angle(degrees: 0)
    @State private var blur1: CGFloat = 5
    @State private var blur2: CGFloat = 5
    @State private var scale: CGFloat = 1

    let text: String = "コンテンツ生成中..."

    var body: some View {
        Text(text)
            .foregroundColor(.gray)
            .font(.headline)
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(white: 0.8))
            }
            .innerShadow(using: .rect(cornerRadius: 20), color: .white, width: 3, blur: 2)
            .multicolorGlowAnimated(
                phase1: phase1,
                phase2: phase2,
                blur1: blur1,
                blur2: blur2
            )
            .scaleEffect(scale)
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: true)) {
                    scale = 1.02
                }

                withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                    phase1 = .degrees(360)
                }

                withAnimation(.linear(duration: 11).repeatForever(autoreverses: false)) {
                    phase2 = .degrees(360)
                }

                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    blur1 = 2
                    blur2 = 7
                }
            }
    }
}


#Preview {
    VStack(alignment: .leading, spacing: 20) {
        NeonCardView4()
    }
}
