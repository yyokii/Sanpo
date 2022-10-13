import SwiftUI

public enum FontName: String {
    case normal = "HiraginoSans-W3"
    case bold = "HiraginoSans-W6"
}

extension View {
    /// Display Japanese font correctly
    /// http://akisute.com/2016/09/ios.html
    public func adaptiveFont(
        _ name: FontName,
        size: CGFloat,
        configure: @escaping (Font) -> Font = { $0 }
    ) -> some View {
        self.modifier(
            AdaptiveFont(
                name: name.rawValue,
                size: size,
                configure: configure
            )
        )
    }
}

private struct AdaptiveFont: ViewModifier {
    let name: String
    let size: CGFloat
    let configure: (Font) -> Font

    func body(content: Content) -> some View {
        // ヒラギノフォントが切れる問題 SwiftUI編 - ObjecTips: https://koze.hatenablog.jp/entry/2020/05/11/093000
        let ctFont = CTFontCreateWithName(
            name as CFString,
            size,
            nil
        )
        let descent = CTFontGetDescent(ctFont)

        return content.font(.init(ctFont))
        .baselineOffset(descent)
        .offset(y: descent / 2)
    }
}

#if DEBUG
struct Font_Previews: PreviewProvider {
    static var previews: some View {

        VStack(alignment: .leading, spacing: 12) {
            ForEach(
                [12, 14, 16, 18, 24, 32, 60].reversed(),
                id: \.self
            ) { fontSize in
                Text("あぷり yqp 漢字")
                    .adaptiveFont(.normal, size: CGFloat(fontSize))
            }

            ForEach(
                [12, 14, 16, 18, 24, 32, 60].reversed(),
                id: \.self
            ) { fontSize in
                Text("あぷり yqp 漢字")
                    .adaptiveFont(.bold, size: CGFloat(fontSize))
            }
        }
    }
}
#endif
