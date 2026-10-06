import Foundation
import Observation

struct DayPoint: Identifiable {
    let day: Date
    let entry: MoodEntry?
    var id: Date { day }
}

@Observable
final class MoodStore {
    private(set) var entries: [MoodEntry] = []
    private let url = URL.documentsDirectory.appending(path: "entries.json")

    init() { load() }

    func add(_ mood: Mood, id: UUID) {
        let entry = MoodEntry(id: id, date: .now,
                              valence: mood.valence, energy: mood.energy,
                              label: mood.label)
        entries.insert(entry, at: 0)
        save()
    }
    
    func week(endingAt date: Date) -> [DayPoint] {
        let cal = Calendar.current
        let end = cal.startOfDay(for: date)
        return (0..<7).reversed().map { offset in
            let day = cal.date(byAdding: .day, value: -offset, to: end) ?? end
            let entry = entries.first { cal.isDate($0.date, inSameDayAs: day) && $0.date <= date }
            return DayPoint(day: day, entry: entry)
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: url) else { return }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        entries = (try? decoder.decode([MoodEntry].self, from: data)) ?? []
    }

    private func save() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(entries) else { return }
        try? data.write(to: url, options: .atomic)
    }

    #if DEBUG
    
    func seed() {
        let now = Date()
        let samples = (0..<12).map { i -> MoodEntry in
            let m = Mood(valence: .random(in: 0...1), energy: .random(in: 0...1))
            return MoodEntry(id: UUID(),
                             date: now.addingTimeInterval(-Double(i + 1) * 86_400),
                             valence: m.valence, energy: m.energy, label: m.label)
        }
        entries.append(contentsOf: samples)
        entries.sort { $0.date > $1.date }
        save()
    }
    #endif
}
