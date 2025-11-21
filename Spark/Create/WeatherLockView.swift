import SwiftUI

struct WeatherLockView: View {
    @EnvironmentObject var weatherService: WeatherService

    let title: String
    let content: String
    let geofence: Geofence?
    let onNext: (Weather?) -> Void

    @State private var selectedWeather: Weather? = nil

    var body: some View {
        VStack(spacing: 24) {

            // ------- Title -------
            Text("Weather Lock")
                .font(BrandStyle.title)

            // ------- Explanatory -------
            Text("Choose a weather condition that must match to unlock your note.")
                .font(BrandStyle.body)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            // ------- Current Weather Preview -------
            if let currentWeather = weatherService.lastWeather {
                VStack(spacing: 8) {
                    Text("Current Weather")
                        .font(BrandStyle.caption)
                        .foregroundColor(BrandStyle.textSecondary)

                    HStack(spacing: 12) {
                        WeatherIcon(weather: currentWeather)
                            .font(.system(size: 28))

                        Text(currentWeather.rawValue.capitalized)
                            .font(BrandStyle.body)

                        Spacer()
                    }
                    .padding()
                    .background(BrandStyle.card)
                    .cornerRadius(12)
                }
            }

            // ------- Weather List -------
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(WeatherOptions, id: \.self) { w in
                        Button {
                            selectedWeather = w
                        } label: {
                            HStack(spacing: 12) {
                                WeatherIcon(weather: w)
                                    .font(.system(size: 24))

                                Text(w.rawValue.capitalized)
                                    .font(BrandStyle.body)

                                Spacer()

                                if selectedWeather == w {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(BrandStyle.accent)
                                }
                            }
                            .padding()
                            .background(BrandStyle.card)
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal)
            }

            Spacer()

            // ------- Buttons -------
            VStack(spacing: 12) {

                Button {
                    onNext(nil)
                } label: {
                    Text("Skip Weather")
                        .font(BrandStyle.button)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray)
                        .cornerRadius(12)
                }

                Button {
                    onNext(selectedWeather)
                } label: {
                    Text("Use Weather")
                        .font(BrandStyle.button)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(BrandStyle.accent)
                        .cornerRadius(12)
                }
            }
        }
        .padding()
    }

    // Available weather options (subset for UI)
    private var WeatherOptions: [Weather] {
        [
            .clear, .partlyCloudy, .cloudy, .foggy,
            .drizzle, .rain, .thunderstorm,
            .snow, .snowGrains
        ]
    }
}


// MARK: - Weather Icons (System Symbols)

struct WeatherIcon: View {
    let weather: Weather

    var body: some View {
        Image(systemName: iconName)
    }

    private var iconName: String {
        switch weather {
        case .clear: return "sun.max.fill"
        case .partlyCloudy: return "cloud.sun.fill"
        case .cloudy: return "cloud.fill"
        case .foggy: return "cloud.fog.fill"
        case .drizzle: return "cloud.drizzle.fill"
        case .rain: return "cloud.rain.fill"
        case .freezingRain: return "cloud.sleet.fill"
        case .snow: return "cloud.snow.fill"
        case .snowGrains: return "cloud.snow"
        case .thunderstorm: return "cloud.bolt.rain.fill"
        case .unknown: return "questionmark.circle"
        }
    }
}
