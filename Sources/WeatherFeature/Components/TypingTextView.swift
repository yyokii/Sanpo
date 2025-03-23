import SwiftUI

struct TypingTextView: View {
    let text: String

    @State private var displayedText = ""
    @State private var currentIndex = 0
    @State private var showCursor = true

    let typingTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var body: some View {
        Group {
            if showCursor {
                Text(displayedText) + Text("●")
            } else {
                Text(displayedText)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .onReceive(typingTimer) { _ in
            if currentIndex < text.count {
                let index = text.index(text.startIndex, offsetBy: currentIndex)
                displayedText.append(text[index])
                currentIndex += 1
            } else {
                showCursor = false
            }
        }
    }
}

#Preview {
    TypingTextView(text: "ここにあなたのテキストが入ります。\nSwiftUIでカーソルが動くアニメーションを実現する例です。テキストは複数行にも対応します。")
    .font(.large)
    .foregroundColor(.purple)
}
