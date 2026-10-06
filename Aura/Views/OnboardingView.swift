import SwiftUI

struct OnboardingView: View {
    let onFinish: () -> Void

    @State private var taps = 0
    @State private var wake = 0.0
    @State private var clock = BlobClock()

    private let moods = [
        Mood(valence: 0.15, energy: 0.20),
        Mood(valence: 0.40, energy: 0.45),
        Mood(valence: 0.70, energy: 0.70),
        Mood(valence: 0.92, energy: 0.90),
    ]
    private let hints = ["dokun", "biraz daha", "bir kez daha", ""]

    var body: some View {
        ZStack {
            TimelineView(.animation) { ctx in
                let f = clock.frame(date: ctx.date, target: moods[taps])
                ZStack {
                    RadialGradient(colors: [f.mood.color().opacity(0.35), .clear],
                                   center: .center, startRadius: 0, endRadius: 450)
                        .ignoresSafeArea()
                    BlobView(phase: f.phase, mood: f.mood)
                        .frame(width: 320, height: 320)
                        .scaleEffect(max(wake, 0.001) * (0.55 + 0.2 * Double(taps)))
                }
            }

            VStack(spacing: 20) {
                Spacer()
                Text(hints[taps])
                    .font(.system(.title3, design: .rounded, weight: .thin))
                    .foregroundStyle(.white.opacity(wake == 1 ? 0.7 : 0))
                    .contentTransition(.opacity)
                    .animation(.easeInOut(duration: 0.4), value: taps)
                    .animation(.easeInOut(duration: 0.6), value: wake)
                HStack(spacing: 10) {
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .fill(.white.opacity(i < taps ? 0.9 : 0.25))
                            .frame(width: 8, height: 8)
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: taps)
                .padding(.bottom, 56)
            }
            .allowsHitTesting(false)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture { tap() }
        .sensoryFeedback(.impact(weight: .light), trigger: taps)
        .task {
            try? await Task.sleep(for: .milliseconds(300))
            withAnimation(.easeInOut(duration: 1.0)) { wake = 0.45 }
            try? await Task.sleep(for: .milliseconds(1000))
            withAnimation(.spring(response: 0.9, dampingFraction: 0.5)) { wake = 1 }
        }
    }

    private func tap() {
        guard wake == 1, taps < 3 else { return }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) { taps += 1 }
        if taps == 3 {
            Task {
                try? await Task.sleep(for: .seconds(1.0))
                onFinish()
            }
        }
    }
}
