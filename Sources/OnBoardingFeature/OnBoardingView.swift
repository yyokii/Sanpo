import SwiftUI

struct OnBoardingView: View {
    enum Path {
        case pathA, pathB, pathC, pathD
    }

    @State private var navigatePath: [Path] = []
    var body: some View {
        NavigationStack(path: $navigatePath) {
            VStack {
                Text("on boarding")

                Button {
                    navigatePath.append(.pathA)
                } label: {
                    Text("next")
                }

            }
            .navigationDestination(for: Path.self) { value in
                switch value {
                case .pathA:
                    Page1(path: $navigatePath)

                case .pathB:
                    Page1(path: $navigatePath)

                case .pathC:
                    Page1(path: $navigatePath)

                case .pathD:
                    Page1(path: $navigatePath)
                }
            }
        }
    }
}

struct Page1: View {
    @Binding var path: [OnBoardingView.Path]

    var body: some View {
        Text("hi page 1")
            .navigationBarBackButtonHidden()
    }
}

#Preview {
    OnBoardingView()
}
