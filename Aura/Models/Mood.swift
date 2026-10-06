import SwiftUI

struct Mood: Equatable {
    var valence: Double   // 0...1  olumsuz → olumlu
    var energy: Double    // 0...1  düşük → yüksek

    var hue: Double { ((240 + 150 * valence).truncatingRemainder(dividingBy: 360)) / 360 }
    var saturation: Double { 0.55 + energy * 0.35 }
    var speed: Double { 0.6 + energy * 1.8 }
    var intensity: Double { 0.4 + energy * 1.2 }

    var color: Color { Color(hue: hue, saturation: saturation, brightness: 0.85) }
    var lightColor: Color { Color(hue: hue, saturation: saturation * 0.6, brightness: 1.0) }

    var label: String {
        let col = valence < 0.33 ? 0 : (valence < 0.66 ? 1 : 2)
        let row = energy > 0.66 ? 0 : (energy > 0.33 ? 1 : 2)
        let labels = [
            ["gergin",   "heyecanlı", "coşkulu"],
            ["huzursuz", "dengeli",   "keyifli"],
            ["bitkin",   "sakin",     "huzurlu"],
        ]
        return labels[row][col]
    }
}
