import SwiftUI

import Extension
import StyleGuide

struct SettingsView: View {

    var body: some View {
        Form {
            Section(header: Text("アプリについて")) {
                SettingsRow(title: "バージョン") {
                    Text(Bundle.main.productVersion)
                }
            }
        }
        .navigationBarTitle("アプリ設定")
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}

/// 設定画面の各項目。タイトルと、特定のviewを表示します。
public struct SettingsRow<Content>: View where Content: View {

    let title: String
    let content: () -> Content

    public init(title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }

    public var body: some View {
        HStack {
            Text(title)
            Spacer()
            content()
        }
        .adaptiveFont(.normal, size: 12)
    }
}

#if DEBUG

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {

        Group {
            SettingsView()
                .environment(\.colorScheme, .light)

            SettingsView()
                .environment(\.colorScheme, .dark)
        }
    }
}

#endif
