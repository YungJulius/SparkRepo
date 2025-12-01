import SwiftUI

struct EarliestUnlockView: View {

    @EnvironmentObject var storage: StorageService

    let title: String
    let content: String
    let geofence: Geofence?
    let weather: Weather?
    let emotion: Emotion?

    @Binding var path: NavigationPath

    var body: some View {
        VStack(spacing: 24) {

            Text("Complete Entry")
                .font(BrandStyle.title)

            Text("Your note will unlock when the conditions you set are met.")
                .font(BrandStyle.body)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            // Debug
            #if DEBUG
            VStack(alignment: .leading, spacing: 4) {
                Text("DEBUG - Received values:")
                    .font(.caption)
                    .foregroundColor(.red)
                Text("Emotion: \(emotion?.rawValue ?? "NIL")").font(.caption)
                Text("Weather: \(weather?.rawValue ?? "NIL")").font(.caption)
                Text("Geofence: \(geofence != nil ? "YES" : "NO")").font(.caption)
            }
            .padding(8)
            .background(Color.red.opacity(0.1))
            .cornerRadius(8)
            #endif

            // Summary
            VStack(alignment: .leading, spacing: 12) {

                if geofence != nil {
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(BrandStyle.accent)
                        Text("Location required")
                            .font(BrandStyle.body)
                    }
                }

                if let w = weather {
                    HStack {
                        Image(systemName: "cloud.fill")
                            .foregroundColor(BrandStyle.accent)
                        Text("Weather: \(w.rawValue.capitalized)")
                            .font(BrandStyle.body)
                    }
                }

                if let emo = emotion {
                    HStack {
                        Image(systemName: "face.smiling")
                            .foregroundColor(BrandStyle.accent)
                        Text("Emotion: \(emo.rawValue.capitalized)")
                            .font(BrandStyle.body)
                    }
                }

                if geofence == nil && weather == nil && emotion == nil {
                    Text("No unlock conditions set - note will unlock immediately")
                        .font(BrandStyle.caption)
                        .foregroundColor(BrandStyle.textSecondary)
                        .italic()
                }
            }
            .padding()
            .background(BrandStyle.card)
            .cornerRadius(12)

            Spacer()

            // Finish
            Button {
                saveEntry()
                path.append("finish")
            } label: {
                Text("Finish")
                    .font(BrandStyle.button)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(BrandStyle.accent)
                    .cornerRadius(12)
            }
        }
        .padding()
    }

    private func saveEntry() {

        print("📝 EarliestUnlockView.saveEntry()")
        print("  Emotion: \(emotion?.rawValue ?? "NIL")")
        print("  Weather: \(weather?.rawValue ?? "NIL")")
        print("  Geofence: \(geofence != nil ? "YES" : "NO")")
        print("  Title: \(title)")
        print("  Content length: \(content.count) chars")

        let entry = SparkEntry(
            title: title,
            content: content,
            geofence: geofence,
            weather: weather,
            emotion: emotion,
            creationDate: Date(),
            unlockedAt: nil
        )

        storage.add(entry)

        print("✅ Entry saved. Total entries: \(storage.entries.count)")
    }
}

#Preview {
    NavigationStack {
        EarliestUnlockView(
            title: "Sample",
            content: "Hello world",
            geofence: nil,
            weather: .rain,
            emotion: .happy,
            path: .constant(NavigationPath())
        )
        .environmentObject(StorageService.shared)
    }
}
