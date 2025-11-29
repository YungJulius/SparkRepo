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
            
            // Debug info
            #if DEBUG
            VStack(alignment: .leading, spacing: 4) {
                Text("DEBUG - Received values:")
                    .font(.caption)
                    .foregroundColor(.red)
                Text("Emotion: \(emotion?.rawValue ?? "NIL")")
                    .font(.caption)
                Text("Weather: \(weather?.rawValue ?? "NIL")")
                    .font(.caption)
                Text("Geofence: \(geofence != nil ? "YES" : "NO")")
                    .font(.caption)
            }
            .padding(8)
            .background(Color.red.opacity(0.1))
            .cornerRadius(8)
            #endif

            // Show conditions summary
            VStack(alignment: .leading, spacing: 12) {
                if geofence != nil {
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(BrandStyle.accent)
                        Text("Location required")
                            .font(BrandStyle.body)
                    }
                }
                
                if weather != nil {
                    HStack {
                        Image(systemName: "cloud.fill")
                            .foregroundColor(BrandStyle.accent)
                        Text("Weather: \(weather!.rawValue.capitalized)")
                            .font(BrandStyle.body)
                    }
                }
                
                if emotion != nil {
                    HStack {
                        Image(systemName: "face.smiling")
                            .foregroundColor(BrandStyle.accent)
                        Text("Emotion: \(emotion!.rawValue.capitalized)")
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

            // Finish button
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
        // Debug: Print what we received
        print("📝 EarliestUnlockView.saveEntry() called")
        print("  Received emotion parameter: \(emotion?.rawValue ?? "NIL")")
        print("  Received weather parameter: \(weather?.rawValue ?? "NIL")")
        print("  Received geofence parameter: \(geofence != nil ? "YES" : "NO")")
        print("  Title: \(title)")
        print("  Content length: \(content.count) chars")
        
        // Time is no longer a requirement - always set to distant past
        // Notes unlock based on emotion/weather/location conditions only
        let earliestUnlock = Date.distantPast

        let entry = SparkEntry(
            title: title,
            content: content,
            geofence: geofence,
            weather: weather,
            emotion: emotion,
            creationDate: Date(),
            earliestUnlock: earliestUnlock,
            unlockedAt: nil
        )

        // Debug: Print to verify data in entry object
        print("🔍 Created SparkEntry object:")
        print("  Title: \(entry.title)")
        print("  Content: \(entry.content.prefix(50))...")
        print("  Geofence: \(entry.geofence != nil ? "YES (\(entry.geofence!.latitude), \(entry.geofence!.longitude))" : "NO")")
        print("  Weather: \(entry.weather?.rawValue ?? "NIL")")
        print("  Emotion: \(entry.emotion?.rawValue ?? "NIL")")
        
        storage.add(entry)
        
        // Verify it was saved
        print("✅ Entry saved. Total entries: \(storage.entries.count)")
        if let saved = storage.entries.last {
            print("  Saved entry has emotion: \(saved.emotion?.rawValue ?? "NIL")")
            print("  Saved entry has weather: \(saved.weather?.rawValue ?? "NIL")")
            print("  Saved entry has geofence: \(saved.geofence != nil ? "YES" : "NO")")
            print("  Saved entry content length: \(saved.content.count) chars")
        }
    }
}

#Preview {
    NavigationStack {
        EarliestUnlockView(
            title: "Sample Title",
            content: "Sample content for preview",
            geofence: nil,
            weather: .rain,
            emotion: .happy,
            path: .constant(NavigationPath())
        )
        .environmentObject(StorageService.shared)
    }
}
