import SwiftUI

struct AnimatedPatchRowTitle: View {
    let text: String

    @State private var isRed = false

    private var staircaseDelay: Double {
        let value = text.unicodeScalars.reduce(0) { partial, scalar in
            partial + Int(scalar.value)
        }
        return Double(value % 7) * 0.12
    }

    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 17, weight: .bold))
            .foregroundStyle(isRed ? AppTheme.accent : Color.white)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
            .shadow(
                color: isRed ? AppTheme.accent.opacity(0.45) : Color.clear,
                radius: 2
            )
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + staircaseDelay) {
                    withAnimation(
                        .easeInOut(duration: 0.60)
                        .repeatForever(autoreverses: true)
                    ) {
                        isRed = true
                    }
                }
            }
    }
}
