//
//  NoteDetailView.swift
//  Spark
//
//  Detailed view for displaying a full note
//

import SwiftUI
import MapKit

struct NoteDetailView: View {
    let entry: SparkEntry
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: entry.isLocked ? "lock.fill" : "lock.open.fill")
                            .font(.system(size: 20))
                            .foregroundColor(entry.isLocked ? .orange : .green)
                        
                        Text(entry.isLocked ? "Locked" : "Unlocked")
                            .font(BrandStyle.sectionTitle)
                            .foregroundColor(entry.isLocked ? .orange : .green)
                        
                        Spacer()
                    }
                    
                    Text("Created: \(entry.creationDate, style: .date)")
                        .font(BrandStyle.caption)
                        .foregroundColor(BrandStyle.textSecondary)
                    
                    if let unlockedAt = entry.unlockedAt {
                        Text("Unlocked: \(unlockedAt, style: .date)")
                            .font(BrandStyle.caption)
                            .foregroundColor(.green)
                    } else {
                        Text("Earliest unlock: \(entry.earliestUnlock, style: .date)")
                            .font(BrandStyle.caption)
                            .foregroundColor(BrandStyle.textSecondary)
                    }
                }
                .padding()
                .background(BrandStyle.card)
                .cornerRadius(12)
                
                // Title
                Text(entry.title)
                    .font(BrandStyle.title)
                    .foregroundColor(BrandStyle.textPrimary)
                
                // Content (only show if unlocked)
                if entry.isLocked {
                    VStack(spacing: 12) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 40))
                            .foregroundColor(BrandStyle.accent.opacity(0.5))
                        
                        Text("This note is locked")
                            .font(BrandStyle.sectionTitle)
                            .foregroundColor(BrandStyle.textPrimary)
                        
                        Text("Meet the unlock conditions to read the content")
                            .font(BrandStyle.body)
                            .foregroundColor(BrandStyle.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                    .background(BrandStyle.card)
                    .cornerRadius(12)
                } else {
                    Text(entry.content)
                        .font(BrandStyle.body)
                        .foregroundColor(BrandStyle.textPrimary)
                        .lineSpacing(4)
                }
                
                // Lock Conditions Section
                if hasAnyLockConditions {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Unlock Conditions")
                            .font(BrandStyle.sectionTitle)
                            .foregroundColor(BrandStyle.textPrimary)
                        
                        // Location condition
                        if let geofence = entry.geofence {
                            HStack(spacing: 12) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(BrandStyle.accent)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Location Required")
                                        .font(BrandStyle.body)
                                        .foregroundColor(BrandStyle.textPrimary)
                                    Text("Within \(Int(geofence.radius))m")
                                        .font(BrandStyle.caption)
                                        .foregroundColor(BrandStyle.textSecondary)
                                }
                                
                                Spacer()
                            }
                            .padding()
                            .background(BrandStyle.card)
                            .cornerRadius(12)
                        }
                        
                        // Weather condition
                        if let weather = entry.weather {
                            HStack(spacing: 12) {
                                WeatherIcon(weather: weather)
                                    .font(.system(size: 24))
                                    .foregroundColor(BrandStyle.accent)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Weather Required")
                                        .font(BrandStyle.body)
                                        .foregroundColor(BrandStyle.textPrimary)
                                    Text(weather.rawValue.capitalized)
                                        .font(BrandStyle.caption)
                                        .foregroundColor(BrandStyle.textSecondary)
                                }
                                
                                Spacer()
                            }
                            .padding()
                            .background(BrandStyle.card)
                            .cornerRadius(12)
                        }
                        
                        // Emotion condition
                        if let emotion = entry.emotion {
                            HStack(spacing: 12) {
                                Image(systemName: emotionIcon(emotion))
                                    .font(.system(size: 24))
                                    .foregroundColor(BrandStyle.accent)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Emotion Required")
                                        .font(BrandStyle.body)
                                        .foregroundColor(BrandStyle.textPrimary)
                                    Text(emotion.rawValue.capitalized)
                                        .font(BrandStyle.caption)
                                        .foregroundColor(BrandStyle.textSecondary)
                                }
                                
                                Spacer()
                            }
                            .padding()
                            .background(BrandStyle.card)
                            .cornerRadius(12)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Note Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var hasAnyLockConditions: Bool {
        entry.geofence != nil || entry.weather != nil || entry.emotion != nil
    }
    
    private func emotionIcon(_ emotion: Emotion) -> String {
        switch emotion {
        case .happy: return "face.smiling"
        case .sad: return "face.dashed"
        case .angry: return "flame.fill"
        case .relaxed: return "leaf.fill"
        case .excited: return "bolt.fill"
        case .stressed: return "exclamationmark.triangle.fill"
        case .bored: return "hourglass"
        case .anxious: return "aqi.low"
        case .grateful: return "hands.sparkles.fill"
        case .calm: return "wind"
        case .energetic: return "figure.run"
        case .tired: return "zzz"
        }
    }
}

#Preview {
    NavigationStack {
        NoteDetailView(
            entry: SparkEntry(
                title: "My First Note",
                content: "This is a detailed view of a note. It shows all the information about the entry including its lock conditions and status.",
                geofence: Geofence(latitude: 37.7749, longitude: -122.4194, radius: 150),
                weather: .rain,
                emotion: .happy
            )
        )
    }
}

