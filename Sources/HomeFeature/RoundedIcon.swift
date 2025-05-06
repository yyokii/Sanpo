import SwiftUI

struct RoundedIcon: View {
    let symbolName: String
    let iconColor: Color

    var body: some View {
        Image(systemName: symbolName)
            .foregroundColor(.white)
            .frame(width: 32, height: 32)
            .bold()
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(iconColor)
            }
    }
}
