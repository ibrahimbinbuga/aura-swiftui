import SwiftUI

struct BlobShape: Shape {
    var phase: Double
    var intensity: Double
    
    var animatableData: AnimatablePair<Double, Double> {
        get { AnimatablePair(phase, intensity) }
        set { phase = newValue.first; intensity = newValue.second }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let base = min(rect.width, rect.height) / 2 * 0.7
        let steps = 120
        for i in 0...steps {
            let a = Double(i) / Double(steps) * 2 * .pi
            let wobble = sin(a * 2 + phase * 0.7) * 0.07 * intensity
                       + sin(a * 3 + phase) * 0.10 * intensity
                       + sin(a * 5 - phase * 1.3) * 0.06 * intensity
            let r = base * (1 + wobble)
            let p = CGPoint(x: center.x + CGFloat(cos(a) * r),
                            y: center.y + CGFloat(sin(a) * r))
            if i == 0 { path.move(to: p) } else { path.addLine(to: p) }
        }
        path.closeSubpath()
        return path
    }
}
