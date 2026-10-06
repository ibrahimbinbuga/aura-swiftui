import SwiftUI

struct DetailView: View {
    let entry: MoodEntry
    let week: [DayPoint]
    let ns: Namespace.ID
    let onBack: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                HStack {
                    Button(action: onBack) {
                        Label("geri", systemImage: "chevron.left")
                    }
                    .font(.system(.body, design: .rounded, weight: .light))
                    .foregroundStyle(.white.opacity(0.8))
                    Spacer()
                }

                MiniBlob(mood: entry.mood)
                    .frame(width: 240, height: 240)
                    .matchedGeometryEffect(id: entry.id, in: ns)

                VStack(spacing: 4) {
                    Text(entry.label)
                        .font(.system(.largeTitle, design: .rounded, weight: .thin))
                    Text(entry.date, format: .dateTime.day().month(.wide).year().hour().minute())
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.white.opacity(0.5))
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("bu hafta")
                        .font(.system(.footnote, design: .rounded))
                        .foregroundStyle(.white.opacity(0.5))
                    WeekChart(week: week)
                }
                .padding(20)
                .glassCard(tint: entry.mood.color())
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .foregroundStyle(.white)
        .background(alignment: .top) {
            RadialGradient(colors: [entry.mood.color().opacity(0.4), .clear],
                           center: .top, startRadius: 0, endRadius: 520)
                .ignoresSafeArea()
        }
    }
}
