import SwiftUI

struct AnimatedPatchRowTitle: View {
    let text: String

    @State private var useAccent = false

    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 17, weight: .bold))
            .foregroundStyle(useAccent ? AppTheme.accent : Color.white)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
            .animation(.easeInOut(duration: 0.75), value: useAccent)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 0.75)
                    .repeatForever(autoreverses: true)
                ) {
                    useAccent = true
                }
            }
    }
}
