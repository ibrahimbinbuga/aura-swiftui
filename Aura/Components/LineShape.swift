import SwiftUI

struct LineShape: Shape {
    let points: [CGPoint]   // 0...1 normalize

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let pts = points.map {
            CGPoint(x: rect.minX + $0.x * rect.width, y: rect.minY + $0.y * rect.height)
        }
        guard let first = pts.first else { return path }
        path.move(to: first)
        for i in 1..<pts.count {
            let a = pts[i - 1], b = pts[i]
            let midX = (a.x + b.x) / 2
            path.addCurve(to: b,
                          control1: CGPoint(x: midX, y: a.y),
                          control2: CGPoint(x: midX, y: b.y))
        }
        return path
    }
}

struct WeekChart: View {
    let week: [DayPoint]
    @State private var appeared = false
    @ScaledMetric(relativeTo: .body) private var chartHeight: CGFloat = 170

    private struct P: Identifiable {
        let id: Int
        let x: Double      // gün sütununun ortası
        let y: Double      // 1 - valence
        let mood: Mood
    }

    private var points: [P] {
        week.enumerated().compactMap { i, d in
            guard let e = d.entry else { return nil }
            return P(id: i, x: (Double(i) + 0.5) / 7, y: 1 - e.valence, mood: e.mood)
        }
    }

    var body: some View {
        VStack(spacing: 10) {
            if points.count < 2 {
                Text("grafik için en az iki günün kaydı gerekiyor")
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))
                    .frame(maxWidth: .infinity, minHeight: chartHeight)
            } else {
                chart.frame(height: chartHeight)
            }

            HStack(spacing: 0) {
                ForEach(week) { d in
                    Text(d.day, format: .dateTime.weekday(.narrow))
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.white.opacity(d.entry == nil ? 0.25 : 0.7))
                }
            }
            .font(.system(.caption, design: .rounded))
        }
        .task {
            try? await Task.sleep(for: .milliseconds(450))   // hero geçişi bitsin
            appeared = true
        }
    }

    private var chart: some View {
        GeometryReader { geo in
            let pad: CGFloat = 10
            let h = geo.size.height - pad * 2

            ZStack {
                LineShape(points: points.map { CGPoint(x: $0.x, y: $0.y) })
                    .trim(from: 0, to: appeared ? 1 : 0)
                    .stroke(
                        LinearGradient(
                            stops: points.map { .init(color: $0.mood.color(), location: $0.x) },
                            startPoint: .leading, endPoint: .trailing),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                    .padding(.vertical, pad)
                    .animation(.easeInOut(duration: 1.2), value: appeared)

                ForEach(points) { p in
                    Circle()
                        .fill(p.mood.color())
                        .frame(width: p.id == 6 ? 14 : 10, height: p.id == 6 ? 14 : 10)
                        .overlay(Circle().strokeBorder(.white.opacity(0.6), lineWidth: 1))
                        .scaleEffect(appeared ? 1 : 0)
                        .animation(.spring(response: 0.4, dampingFraction: 0.6)
                                    .delay(0.1 + 1.0 * p.x), value: appeared)
                        .position(x: p.x * geo.size.width, y: pad + p.y * h)
                }
            }
        }
    }
}
