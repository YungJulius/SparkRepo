import SwiftUI
import CoreLocation
import Combine
import Foundation

struct SparkEntry: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var content: String
    var creationDate: Date

    // unlock triggers
    var geofence: Geofence?
    var weather: Weather?
    var emotion: Emotion?

    // unlock state
    var unlockedAt: Date?   // nil = locked

    init(
        id: UUID = UUID(),
        title: String,
        content: String,
        geofence: Geofence? = nil,
        weather: Weather? = nil,
        emotion: Emotion? = nil,
        creationDate: Date = Date(),
        unlockedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.creationDate = creationDate
        self.geofence = geofence
        self.weather = weather
        self.emotion = emotion
        self.unlockedAt = unlockedAt
    }

    var isLocked: Bool {
        unlockedAt == nil
    }
}

final class StorageService: ObservableObject {
    static let shared = StorageService()

    @Published var entries: [SparkEntry] = []

    private init() {}

    private var fileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("sparkEntries.json")
    }

    func load() {
        let fileExists = FileManager.default.fileExists(atPath: fileURL.path)

        if fileExists {
            if let data = try? Data(contentsOf: fileURL),
               let decoded = try? JSONDecoder().decode([SparkEntry].self, from: data) {
                entries = decoded
                print("📂 Loaded \(entries.count) entries from disk")
                for (index, entry) in entries.enumerated() {
                    print("  Entry \(index): title=\(entry.title), emotion=\(entry.emotion?.rawValue ?? "nil"), weather=\(entry.weather?.rawValue ?? "nil"), geofence=\(entry.geofence != nil ? "yes" : "no")")
                }
            } else {
                print("⚠️ Failed to decode entries, starting fresh")
                entries = []
                save()
            }
        } else {
            print("📂 No saved file found, starting fresh")
            entries = []
        }
    }

    // ----------------------------------------------------------
    // Demo Notes (cleaned, no earliestUnlock anymore)
    // ----------------------------------------------------------
    func addDemoNotes() {
        createDemoNotes()
    }

    func createDemoNotes() {
        let calendar = Calendar.current
        let now = Date()

        let demo1 = SparkEntry(
            title: "Memories from Central Park",
            content: "I remember walking through Central Park...",
            geofence: Geofence(latitude: 40.7851, longitude: -73.9683, radius: 150),
            creationDate: calendar.date(byAdding: .day, value: -5, to: now)!
        )

        let demo2 = SparkEntry(
            title: "Grateful for Today",
            content: "Today was amazing!",
            emotion: .grateful,
            creationDate: calendar.date(byAdding: .day, value: -7, to: now)!,
            unlockedAt: calendar.date(byAdding: .hour, value: -2, to: now)!
        )

        let demo3 = SparkEntry(
            title: "Rainy Day Thoughts",
            content: "There's something peaceful about rainy days...",
            weather: .rain,
            creationDate: calendar.date(byAdding: .day, value: -3, to: now)!
        )

        let demo4 = SparkEntry(
            title: "Celebration Note",
            content: "I want to capture this moment of pure joy!",
            emotion: .happy,
            creationDate: calendar.date(byAdding: .day, value: -10, to: now)!
        )

        let demo5 = SparkEntry(
            title: "Beach Sunset Memory",
            content: "The perfect beach sunset...",
            geofence: Geofence(latitude: 34.0522, longitude: -118.2437, radius: 200),
            weather: .clear,
            creationDate: calendar.date(byAdding: .day, value: -14, to: now)!
        )

        let demo6 = SparkEntry(
            title: "Morning Reflection",
            content: "Early mornings have become my favorite time.",
            creationDate: calendar.date(byAdding: .day, value: -20, to: now)!,
            unlockedAt: calendar.date(byAdding: .day, value: -1, to: now)!
        )

        let demo7 = SparkEntry(
            title: "Winter Wonderland",
            content: "Snow days are magical.",
            weather: .snow,
            creationDate: calendar.date(byAdding: .day, value: -2, to: now)!
        )

        let demo8 = SparkEntry(
            title: "Perfect Day Memory",
            content: "Everything aligned perfectly that day...",
            geofence: Geofence(latitude: 37.7749, longitude: -122.4194, radius: 150),
            weather: .partlyCloudy,
            emotion: .calm,
            creationDate: calendar.date(byAdding: .day, value: -8, to: now)!
        )

        let demo9 = SparkEntry(
            title: "Future Me",
            content: "Hey future me!",
            creationDate: calendar.date(byAdding: .hour, value: -12, to: now)!
        )

        let demo10 = SparkEntry(
            title: "Quick Note",
            content: "Just a quick thought...",
            emotion: .excited,
            creationDate: calendar.date(byAdding: .day, value: -4, to: now)!,
            unlockedAt: calendar.date(byAdding: .hour, value: -5, to: now)!
        )

        entries = [
            demo1, demo2, demo3, demo4, demo5,
            demo6, demo7, demo8, demo9, demo10
        ]

        save()
    }

    // ----------------------------------------------------------
    // Save / Add / Update / Clear
    // ----------------------------------------------------------

    func save() {
        print("💾 Saving \(entries.count) entries to disk")
        for (index, entry) in entries.enumerated() {
            print("  Entry \(index): title=\(entry.title), emotion=\(entry.emotion?.rawValue ?? "nil"), weather=\(entry.weather?.rawValue ?? "nil"), geofence=\(entry.geofence != nil ? "yes" : "no")")
        }

        if let data = try? JSONEncoder().encode(entries) {
            try? data.write(to: fileURL, options: .atomic)
            print("✅ Saved successfully to \(fileURL.path)")
        } else {
            print("❌ Failed to encode entries")
        }
    }

    func add(_ entry: SparkEntry) {
        entries.append(entry)
        save()
    }

    func update(_ entry: SparkEntry) {
        if let i = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[i] = entry
            save()
        }
    }

    func clearAll() {
        entries = []
        save()
    }
}
