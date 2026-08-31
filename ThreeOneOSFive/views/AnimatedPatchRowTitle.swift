import SwiftUI

struct AnimatedPatchRowTitle: View {
    let text: String

    @State private var isRed = false

    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 17, weight: .bold))
            .foregroundStyle(isRed ? AppTheme.accent : Color.white)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
            .shadow(
                color: isRed ? AppTheme.accent.opacity(0.42) : Color.clear,
                radius: 2
            )
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 0.60)
                    .repeatForever(autoreverses: true)
                ) {
                    isRed = true
                }
            }
    }
}
