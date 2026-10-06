import SwiftUI

struct MoodPickerView: View {
    let ns: Namespace.ID
    let blobID: UUID
    let hasHistory: Bool
    let onSave: (Mood) -> Void
    let onHistory: () -> Void

    @State private var mood = Mood(valence: 0.5, energy: 0.4)
    @State private var clock = BlobClock()
    @State private var pressed = false
    @State private var saveCount = 0
    private let inset: CGFloat = 110

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width - inset * 2
            let h = geo.size.height - inset * 2

            ZStack {
                TimelineView(.animation) { ctx in
                    let f = clock.frame(date: ctx.date, target: mood)
                    let x = inset + f.mood.valence * w
                    let y = inset + (1 - f.mood.energy) * h
                    ZStack {
                        RadialGradient(
                            colors: [f.mood.color().opacity(0.35), .clear],
                            center: UnitPoint(x: x / geo.size.width, y: y / geo.size.height),
                            startRadius: 0, endRadius: 450)
                            .ignoresSafeArea()

                        BlobView(phase: f.phase, mood: f.mood)
                            .frame(width: 320, height: 320)
                            .scaleEffect(pressed ? 1.12 : 1)
                            .animation(.spring(response: 0.35, dampingFraction: 0.55), value: pressed)
                            .offset(x: x - geo.size.width / 2, y: y - geo.size.height / 2)
                            .matchedGeometryEffect(id: blobID, in: ns)
                    }
                }
                .allowsHitTesting(false)

                Color.clear
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { v in
                                pressed = true
                                mood.valence = min(max((v.location.x - inset) / w, 0), 1)
                                mood.energy  = 1 - min(max((v.location.y - inset) / h, 0), 1)
                            }
                            .onEnded { _ in pressed = false }
                    )

                VStack {
                    HStack {
                        Spacer()
                        if hasHistory {
                            Button("geçmiş", action: onHistory)
                                .font(.system(size: 18, weight: .light, design: .rounded))
                                .foregroundStyle(.white.opacity(0.8))
                        }
                    }
                    .padding(.horizontal, 24)

                    Spacer()

                    Text(mood.label)
                        .font(.system(size: 44, weight: .thin, design: .rounded))
                        .foregroundStyle(.white.opacity(0.9))
                        .contentTransition(.opacity)
                        .animation(.easeInOut(duration: 0.25), value: mood.label)
                        .allowsHitTesting(false)

                    Button {
                        saveCount += 1
                        onSave(mood)
                    } label: {
                        Text("kaydet")
                            .font(.system(size: 20, weight: .light, design: .rounded))
                            .padding(.horizontal, 36)
                            .padding(.vertical, 14)
                            .background(.white.opacity(0.1), in: Capsule())
                            .overlay(Capsule().strokeBorder(.white.opacity(0.2), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.white)
                    .padding(.top, 12)
                    .padding(.bottom, 40)
                }
            }
        }
        .sensoryFeedback(.selection, trigger: mood.label)
        .sensoryFeedback(.success, trigger: saveCount)
    }
}
