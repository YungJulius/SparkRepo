import SwiftUI

struct EmotionLockView: View {
    @EnvironmentObject var storage: StorageService

    // Data passed from CreateView
    let title: String
    let content: String
    @Binding var geofence: Geofence?
    @Binding var weather: Weather?

    // Bind back to CreateView
    @Binding var emotion: Emotion?
    @Binding var path: NavigationPath

    @State private var selectedEmotion: Emotion? = nil

    var body: some View {
        VStack(spacing: 24) {

            // ------- Title -------
            Text("Emotion Lock")
                .font(BrandStyle.title)

            // ------- Explanation -------
            Text("Choose an emotion that must match to unlock your note.")
                .font(BrandStyle.body)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            // ------- Emotion List -------
            ScrollView {
                VStack(spacing: 0) {

                    ForEach(Emotion.allCases, id: \.self) { emo in

                        EmotionRow(
                            emotion: emo,
                            isSelected: selectedEmotion == emo
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(selectedEmotion == emo ? BrandStyle.accent : .white)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedEmotion = emo
                        }

                        if emo != Emotion.allCases.last {
                            Rectangle()
                                .fill(BrandStyle.accent.opacity(0.2))
                                .frame(height: 1)
                        }
                    }
                }
            }
            .frame(maxHeight: 400)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(BrandStyle.accent, lineWidth: 1)
            )

            Spacer()

            VStack(spacing: 12) {

                // Skip
                Button {
                    emotion = nil
                    saveEntryHere()
                    path.append(CreateFlowStep.finish)
                } label: {
                    Text("Skip Emotion")
                        .font(BrandStyle.button)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray)
                        .cornerRadius(12)
                }

                // Use Emotion
                Button {
                    if let emo = selectedEmotion {
                        emotion = emo
                        saveEntryHere()
                        path.append(CreateFlowStep.finish)
                    }
                } label: {
                    Text("Use Emotion")
                        .font(BrandStyle.button)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedEmotion != nil ? BrandStyle.accent : Color.gray)
                        .cornerRadius(12)
                }
                .disabled(selectedEmotion == nil)
            }
        }
        .padding()
        .onAppear {
            // Re-sync if user returns back
            selectedEmotion = emotion
        }
    }

    // MARK: - Save Entry Right Here (Option B)
    private func saveEntryHere() {
        let entry = SparkEntry(
            title: title,
            content: content,
            geofence: geofence,
            weather: weather,
            emotion: selectedEmotion,  // nil if skipped
            creationDate: Date(),
            unlockedAt: nil
        )

        storage.add(entry)
    }
}


// MARK: - Row
private struct EmotionRow: View {
    let emotion: Emotion
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {

            Image(systemName: iconName)
                .font(.system(size: 24))
                .foregroundColor(isSelected ? .white : .black)

            Text(emotion.rawValue.capitalized)
                .font(BrandStyle.body)
                .foregroundColor(isSelected ? .white : .black)

            Spacer()

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.white)
            }
        }
        .padding(.vertical, 6)
    }

    private var iconName: String {
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

