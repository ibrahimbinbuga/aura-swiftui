import SwiftUI

struct Mood: Equatable {
    var valence: Double
    var energy: Double

    private var v: Double { min(max(valence, 0), 1) }
    private var e: Double { min(max(energy, 0), 1) }

    var hue: Double { ((240 + 150 * v).truncatingRemainder(dividingBy: 360)) / 360 }
    var saturation: Double { 0.55 + e * 0.35 }
    var speed: Double { 0.6 + e * 1.8 }
    var intensity: Double { 0.4 + e * 1.2 }

    func color(shift: Double = 0) -> Color {
        Color(hue: (hue + shift + 1).truncatingRemainder(dividingBy: 1),
              saturation: saturation, brightness: 0.9)
    }
    func lightColor(shift: Double = 0) -> Color {
        Color(hue: (hue + shift + 1).truncatingRemainder(dividingBy: 1),
              saturation: saturation * 0.5, brightness: 1.0)
    }

    var label: String {
        let col = v < 0.33 ? 0 : (v < 0.66 ? 1 : 2)
        let row = e > 0.66 ? 0 : (e > 0.33 ? 1 : 2)
        let labels = [
            ["gergin",   "heyecanlı", "coşkulu"],
            ["huzursuz", "dengeli",   "keyifli"],
            ["bitkin",   "sakin",     "huzurlu"],
        ]
        return labels[row][col]
    }
}
