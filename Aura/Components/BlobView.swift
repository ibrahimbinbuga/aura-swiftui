import SwiftUI

final class BlobClock {
    private var last: Date?
    private(set) var phase = 0.0
    private var v = 0.5, e = 0.4
    private var vv = 0.0, ve = 0.0

    func frame(date: Date, target: Mood) -> (phase: Double, mood: Mood) {
        defer { last = date }
        guard let prev = last else {
            v = target.valence; e = target.energy
            return (phase, Mood(valence: v, energy: e))
        }
        let dt = min(date.timeIntervalSince(prev), 1.0 / 30)
        let k = 140.0, c = 11.0
        vv += (k * (target.valence - v) - c * vv) * dt
        ve += (k * (target.energy  - e) - c * ve) * dt
        v += vv * dt
        e += ve * dt
        let shown = Mood(valence: v, energy: e)
        phase += dt * shown.speed
        return (phase, shown)
    }
}

struct BlobView: View {
    let phase: Double
    let mood: Mood

    var body: some View {
        GeometryReader { geo in
            let s = min(geo.size.width, geo.size.height) / 320
            ZStack {
                layer(scale: 1.25, shift: -0.07, offset: 2.1, blur: 30 * s, opacity: 0.55, s: s)
                layer(scale: 1.10, shift:  0.06, offset: 4.2, blur: 16 * s, opacity: 0.75, s: s)
                layer(scale: 1.00, shift:  0.00, offset: 0.0, blur: 5 * s,  opacity: 1.0,  s: s)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .scaleEffect(1 + 0.04 * sin(phase * 0.6))
            .shadow(color: mood.color().opacity(0.55), radius: 60 * s)
        }
    }

    private func layer(scale: CGFloat, shift: Double, offset: Double,
                       blur: CGFloat, opacity: Double, s: CGFloat) -> some View {
        BlobShape(phase: phase + offset, intensity: mood.intensity)
            .fill(RadialGradient(colors: [mood.lightColor(shift: shift), mood.color(shift: shift)],
                                 center: .center, startRadius: 0, endRadius: 180 * s))
            .scaleEffect(scale)
            .blur(radius: blur)
            .opacity(opacity)
            .blendMode(.plusLighter)
    }
}
