import Foundation

struct MoodEntry: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    let valence: Double
    let energy: Double
    let label: String

    var mood: Mood { Mood(valence: valence, energy: energy) }
}
