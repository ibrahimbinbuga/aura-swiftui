import SwiftUI

struct MiniBlob: View {
    let mood: Mood
    @State private var live = false
    @State private var clock = BlobClock()

    var body: some View {
        TimelineView(.animation(paused: !live)) { ctx in
            let f = clock.frame(date: ctx.date, target: mood)
            BlobView(phase: f.phase, mood: f.mood)
        }
        .onAppear { live = true }
        .onDisappear { live = false }
    }
}

struct MoodCard: View {
    let entry: MoodEntry
    let ns: Namespace.ID

    var body: some View {
        HStack(spacing: 16) {
            MiniBlob(mood: entry.mood)
                .frame(width: 56, height: 56)
                .matchedGeometryEffect(id: entry.id, in: ns)

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.label)
                    .font(.system(size: 26, weight: .light, design: .rounded))
                Text(entry.date, format: .dateTime.day().month(.wide).hour().minute())
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))
            }
            Spacer()
        }
        .foregroundStyle(.white)
        .padding(20)
        .frame(height: 132, alignment: .bottom)
        .glassCard(tint: entry.mood.color(), interactive: true)
    }
}
