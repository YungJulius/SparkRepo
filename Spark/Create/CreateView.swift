import SwiftUI
import CoreLocation

// MARK: - Navigation Enum
enum CreateFlowStep: Hashable {
    case location
    case weather
    case emotion
    case finish
}

struct CreateView: View {
    @EnvironmentObject var location: LocationService
    @EnvironmentObject var weather: WeatherService
    @EnvironmentObject var emotion: EmotionService
    @EnvironmentObject var storage: StorageService

    @State private var path = NavigationPath()
    @State private var title: String = ""
    @State private var content: String = ""

    // Unlock conditions shared across screens
    @State private var geofence: Geofence? = nil
    @State private var weatherCondition: Weather? = nil
    @State private var emotionCondition: Emotion? = nil

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 16) {

                // --- Title Field ---
                VStack(alignment: .leading, spacing: 4) {
                    Text("Title")
                        .font(BrandStyle.caption)
                        .foregroundColor(BrandStyle.textSecondary)

                    TextField("New Entry Title", text: $title)
                        .padding(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(BrandStyle.accent, lineWidth: 1)
                        )
                }

                // --- Content Field ---
                VStack(alignment: .leading, spacing: 4) {
                    Text("Content")
                        .font(BrandStyle.caption)
                        .foregroundColor(BrandStyle.textSecondary)

                    TextEditor(text: $content)
                        .padding(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(BrandStyle.accent, lineWidth: 1)
                        )
                        .frame(maxHeight: .infinity)
                }

                // --- Next Button ---
                Button {
                    path.append(CreateFlowStep.location)
                } label: {
                    Text("Next")
                        .font(BrandStyle.button)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(BrandStyle.accent)
                        .cornerRadius(12)
                }
            }
            .padding()
            .navigationTitle("Create Entry")
            .navigationDestination(for: CreateFlowStep.self) { step in
                switch step {

                case .location:
                    LocationLockView(
                        geofence: $geofence,
                        path: $path
                    )

                case .weather:
                    WeatherLockView(
                        geofence: $geofence,
                        weather: $weatherCondition,
                        path: $path
                    )

                case .emotion:
                    EmotionLockView(
                        title: title,
                        content: content,
                        geofence: $geofence,
                        weather: $weatherCondition,
                        emotion: $emotionCondition,
                        path: $path
                    )

                case .finish:
                    FinishedView(path: $path)
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .resetCreateFlow)) { _ in
            resetFlow()
        }
    }

    private func resetFlow() {
        title = ""
        content = ""
        geofence = nil
        weatherCondition = nil
        emotionCondition = nil
        path = NavigationPath()
    }
}

#Preview {
    CreateView()
        .environmentObject(LocationService())
        .environmentObject(WeatherService())
        .environmentObject(EmotionService.shared)
        .environmentObject(StorageService.shared)
}
