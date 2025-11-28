//
//  HomeView.swift
//  Spark
//
//  Created by Julius  Jung on 20.11.2025.
//



import SwiftUI
import CoreLocation
import Combine

struct HomeView: View {
    @EnvironmentObject var location: LocationService
    @EnvironmentObject var weather: WeatherService
    @EnvironmentObject var emotion: EmotionService
    @EnvironmentObject var storage: StorageService
    
    @State private var selectedEmotion: Emotion?
    @State private var currentWeather: Weather?
    @State private var placeName: String = "-"
    
    private var recentUnlocked: [SparkEntry] {
        storage.entries
            .filter { $0.unlockedAt != nil }
            .sorted { ($0.unlockedAt ?? .distantPast) > ($1.unlockedAt ?? .distantPast) }
    }
    
    @State private var isRefreshing = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Spark")
                        .font(BrandStyle.title)
                        .foregroundColor(BrandStyle.accent)
                    Text("Welcome Back")
                        .font(BrandStyle.sectionTitle)
                        .foregroundColor(.black)
                }
                SectionHeader("Mood Picker")
                EmotionPicker(
                    selected: selectedEmotion,
                    onSelect: { setEmotion($0) }
                )
                SectionHeader("Status")
                VStack(spacing: 12) {
                    StatusCard(
                        title: "Weather",
                        subtitle: currentWeather?.rawValue.capitalized ?? "-",
                        symbol: WeatherSymbol.symbol(for: currentWeather ?? .unknown)
                    )
                    StatusCard(
                        title: "Location",
                        subtitle: placeName,
                        symbol: "mappin.and.ellipse"
                    )
                    RefreshCard(isLoading: isRefreshing) { refresh() }
                }
                
                SectionHeader("Recently Unlocked")
                VStack(spacing: 12) {
                    if recentUnlocked.isEmpty {
                        Text("No unlocked entries yet.")
                            .font(BrandStyle.body)
                            .foregroundColor(.black.opacity(0.6))
                    } else {
                        ForEach(recentUnlocked.prefix(5), id: \.id) { entry in
                            RecentEntryCard(entry: entry)
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(Color.white.ignoresSafeArea())
        .task { await load() }
        .onAppear { location.requestPermission() }
        .onReceive(location.$currentLocation.compactMap { $0 }) { loc in
            Task { await updateForCoordinate(loc.coordinate) }
        }
        .onReceive(weather.$lastWeather.compactMap { $0 }) { w in
            currentWeather = w
        }
        .refreshable { await load() }
    }
    
    private func refresh() {
        Task { await load() }
    }
    
    private func setEmotion(_ newValue: Emotion?) {
        if let value = newValue {
            emotion.setEmotion(value)
        }
        selectedEmotion = newValue
    }
    
    @MainActor
    private func load() async {
        isRefreshing = true
        
        selectedEmotion = emotion.currentEmotion
        
        if let coord = location.currentLocation?.coordinate {
            placeName = await reverseGeocode(coord)
            do {
                currentWeather = try await weather.fetchWeather(
                    lat: coord.latitude, lon: coord.longitude
                )
            } catch {
                currentWeather = weather.lastWeather
            }
        } else {
            placeName = "-"
            currentWeather = weather.lastWeather
        }
        
        storage.load()
        isRefreshing = false
    }
    
    @MainActor
    private func updateForCoordinate(_ coord: CLLocationCoordinate2D) async {
        placeName = await reverseGeocode(coord)
        do {
            currentWeather = try await weather.fetchWeather(lat: coord.latitude, lon: coord.longitude
            )
        } catch {
            currentWeather = weather.lastWeather
        }
    }
    
    @ViewBuilder
    private func SectionHeader(_ text: String) -> some View {
        Text(text)
            .font(BrandStyle.sectionTitle)
            .foregroundColor(BrandStyle.accent)
    }
    
    private struct EmotionPicker: View {
        let selected: Emotion?
        let onSelect: (Emotion?) -> Void
        
        private let columns = [GridItem(.flexible()), GridItem(.flexible())]
        
        var body: some View {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(Emotion.allCases, id: \.self) { emo in
                    EmotionChip(
                        emotion: emo,
                        isSelected: selected == emo,
                        onTap: { onSelect(emo) }
                    )
                }
                HStack {
                    Spacer()
                    Button { onSelect(nil) } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "xmark.circle")
                                .font(.system(size: 16, weight: .regular))
                            Text("Clear")
                                .font(BrandStyle.button)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(BrandStyle.accent.opacity(0.12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(BrandStyle.accent, lineWidth: 1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .foregroundColor(.black)
                    }
                    .buttonStyle(.plain)
                    Spacer()
                }
                .gridCellColumns(2)
            }
        }
    }
    
    private struct EmotionChip: View {
        let emotion: Emotion
        let isSelected: Bool
        let onTap: () -> Void
        
        var body: some View {
            Button(action: onTap) {
                HStack(spacing: 8) {
                    Image(systemName: iconName)
                        .font(.system(size: 16, weight: .regular))
                    Text(emotion.rawValue.capitalized)
                        .font(BrandStyle.caption)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSelected ? BrandStyle.accent.opacity(0.18)
                            :BrandStyle.accent.opacity(0.10))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? BrandStyle.accent : BrandStyle.accent.opacity(0.6), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .foregroundColor(.black)
            }
            .buttonStyle(.plain)
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
    
    private struct StatusCard: View {
        let title: String
        let subtitle: String
        let symbol: String
        
        var body: some View {
            HStack(spacing: 12) {
                Image(systemName: symbol)
                    .font(.system(size: 22, weight: .regular))
                    .foregroundColor(BrandStyle.accent)
                    .frame(width: 40, height: 40)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(BrandStyle.caption)
                        .foregroundColor(.black.opacity(0.7))
                    Text(subtitle)
                        .font(BrandStyle.body)
                        .foregroundColor(.black)
                }
                Spacer()
            }
            .padding(12)
            .background(BrandStyle.accent.opacity(0.10))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.black.opacity(0.06), lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
    
    private struct RefreshCard: View {
        let isLoading: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                        .rotationEffect(.degrees(isLoading ? 360 : 0))
                        .animation(
                            isLoading ? .linear(duration: 0.8).repeatForever(autoreverses: false) : .default,
                            value: isLoading
                        )
                    Text("Refresh")
                        .font(BrandStyle.caption)
                }
                .foregroundColor(.black)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(BrandStyle.accent.opacity(0.18))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(BrandStyle.accent, lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
        }
    }
    
    private struct RecentEntryCard: View {
        let entry: SparkEntry
        
        var body: some View {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(BrandStyle.accent)
                    .frame(width: 40, height: 40)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.title)
                        .font(BrandStyle.body)
                        .foregroundColor(.black)
                        .lineLimit(1)
                    Text(entry.content)
                        .font(BrandStyle.caption)
                        .foregroundColor(.black.opacity(0.75))
                        .lineLimit(2)
                }
                Spacer()
                
                Image(systemName: "lock.open")
                    .foregroundColor(.black.opacity(0.7))
            }
            .padding(12)
            .background(BrandStyle.accent.opacity(0.10))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.black.opacity(0.06), lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
    
    private func reverseGeocode(_ coord: CLLocationCoordinate2D) async -> String {
        do {
            let geocoder = CLGeocoder()
            let placemarks = try await geocoder.reverseGeocodeLocation(
                CLLocation(latitude: coord.latitude, longitude: coord.longitude)
            )
            return placemarks.first?.locality ?? placemarks.first?.name ?? "-"
        } catch {
            return "-"
        }
    }
    
    
    private enum WeatherSymbol {
        static func symbol(for w: Weather) -> String {
            switch w{
            case .clear: return "sun.max.fill"
            case .partlyCloudy: return "cloud.sun.fill"
            case .cloudy: return "cloud.fill"
            case .foggy: return "cloud.fog.fill"
            case .drizzle: return "cloud.drizzle.fill"
            case .rain: return "cloud.rain.fill"
            case .freezingRain: return "cloud.sleet.fill"
            case .snow: return "cloud.snow.fill"
            case .snowGrains: return "snowflake"
            case .thunderstorm: return "cloud.bolt.rain.fill"
            case .unknown: return "questionmark.circle"
            }
        }
    }
}
    
#Preview {
    HomeView()
        .environmentObject(LocationService())
        .environmentObject(WeatherService())
        .environmentObject(EmotionService.shared)
        .environmentObject(StorageService.shared)
}

#Preview {
    HomeView()
}
