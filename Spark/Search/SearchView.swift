//
//  SearchView.swift
//  Spark
//
//  Created by Julius  Jung on 20.11.2025.
//

import SwiftUI

enum FilterOption: String, CaseIterable {
    case all = "All"
    case locked = "Locked"
    case unlocked = "Unlocked"
}

enum SortOption: String, CaseIterable {
    case newest = "Newest First"
    case oldest = "Oldest First"
    case recentlyUnlocked = "Recently Unlocked"
}

struct SearchView: View {
    @EnvironmentObject var storage: StorageService
    
    @State private var searchText: String = ""
    @State private var selectedFilter: FilterOption = .all
    @State private var selectedSort: SortOption = .newest
    @State private var selectedEmotion: Emotion? = nil
    @State private var selectedWeather: Weather? = nil
    @State private var showFilters = false
    @State private var selectedEntry: SparkEntry? = nil
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Debug: Show entry count and clear button (for testing)
                #if DEBUG
                HStack {
                    Text("Entries: \(storage.entries.count)")
                        .font(BrandStyle.caption)
                        .foregroundColor(BrandStyle.textSecondary)
                    
                    Spacer()
                    
                    Button("Clear All") {
                        storage.clearAll()
                    }
                    .font(BrandStyle.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        LinearGradient(
                            colors: [Color.red, Color.red.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(10)
                    .shadow(color: Color.red.opacity(0.3), radius: 4, x: 0, y: 2)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                #endif
                
                // Search Bar
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(BrandStyle.secondary)
                        .font(.system(size: 16, weight: .medium))
                    
                    TextField("Search notes...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(BrandStyle.body)
                    
                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(BrandStyle.textSecondary)
                                .font(.system(size: 18))
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(BrandStyle.card)
                .cornerRadius(14)
                .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(BrandStyle.secondary.opacity(0.2), lineWidth: 1)
                )
                .padding(.horizontal)
                .padding(.top)
                
                // Filter and Sort Controls
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        // Filter Button
                        Menu {
                            Picker("Filter", selection: $selectedFilter) {
                                ForEach(FilterOption.allCases, id: \.self) { option in
                                    Text(option.rawValue).tag(option)
                                }
                            }
                            
                            Divider()
                            
                            Picker("Sort", selection: $selectedSort) {
                                ForEach(SortOption.allCases, id: \.self) { option in
                                    Text(option.rawValue).tag(option)
                                }
                            }
                            
                            Divider()
                            
                            Menu("Filter by Emotion") {
                                Button("All") {
                                    selectedEmotion = nil
                                }
                                ForEach(Emotion.allCases, id: \.self) { emotion in
                                    Button(emotion.rawValue.capitalized) {
                                        selectedEmotion = emotion
                                    }
                                }
                            }
                            
                            Menu("Filter by Weather") {
                                Button("All") {
                                    selectedWeather = nil
                                }
                                ForEach([Weather.clear, .partlyCloudy, .cloudy, .foggy, .drizzle, .rain, .snow, .thunderstorm], id: \.self) { weather in
                                    Button(weather.rawValue.capitalized) {
                                        selectedWeather = weather
                                    }
                                }
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "line.3.horizontal.decrease.circle")
                                    .font(.system(size: 14, weight: .medium))
                                Text("Filters")
                            }
                            .font(BrandStyle.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                LinearGradient(
                                    colors: [BrandStyle.accent, BrandStyle.accent.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(10)
                            .shadow(color: BrandStyle.accent.opacity(0.3), radius: 4, x: 0, y: 2)
                        }
                        
                        // Active filters display
                        if selectedFilter != .all {
                            FilterChip(
                                text: selectedFilter.rawValue,
                                onRemove: { selectedFilter = .all }
                            )
                        }
                        
                        if selectedEmotion != nil {
                            FilterChip(
                                text: selectedEmotion!.rawValue.capitalized,
                                onRemove: { selectedEmotion = nil }
                            )
                        }
                        
                        if selectedWeather != nil {
                            FilterChip(
                                text: selectedWeather!.rawValue.capitalized,
                                onRemove: { selectedWeather = nil }
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
                
                // Results
                if filteredEntries.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "note.text")
                            .font(.system(size: 56, weight: .light))
                            .foregroundColor(BrandStyle.secondary.opacity(0.4))
                        
                        Text("No notes found")
                            .font(BrandStyle.sectionTitle)
                            .foregroundColor(BrandStyle.textPrimary)
                        
                        if !searchText.isEmpty || selectedFilter != .all || selectedEmotion != nil || selectedWeather != nil {
                            Text("Try adjusting your search or filters")
                                .font(BrandStyle.body)
                                .foregroundColor(BrandStyle.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        } else {
                            Text("Create your first note to get started")
                                .font(BrandStyle.body)
                                .foregroundColor(BrandStyle.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 60)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            ForEach(filteredEntries) { entry in
                                NoteCardView(entry: entry) {
                                    // Only set selected entry if unlocked
                                    if !entry.isLocked {
                                        selectedEntry = entry
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbarBackground(BrandStyle.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationDestination(item: $selectedEntry) { entry in
                NoteDetailView(entry: entry)
            }
            .onAppear {
                // Refresh entries when view appears to ensure latest data is shown
                storage.load()
            }
            .background(
                LinearGradient(
                    colors: [
                        BrandStyle.primary.opacity(0.03),
                        BrandStyle.background
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }
    
    // MARK: - Filtered Entries
    private var filteredEntries: [SparkEntry] {
        var entries = storage.entries
        
        // Search filter
        if !searchText.isEmpty {
            entries = entries.filter { entry in
                entry.title.localizedCaseInsensitiveContains(searchText) ||
                entry.content.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Lock status filter
        switch selectedFilter {
        case .all:
            break
        case .locked:
            entries = entries.filter { $0.isLocked }
        case .unlocked:
            entries = entries.filter { !$0.isLocked }
        }
        
        // Emotion filter - only show entries that have this emotion as a condition
        if let emotion = selectedEmotion {
            entries = entries.filter { entry in
                // Explicitly check if entry has this emotion set
                guard let entryEmotion = entry.emotion else { return false }
                return entryEmotion == emotion
            }
        }
        
        // Weather filter - only show entries that have this weather as a condition
        if let weather = selectedWeather {
            entries = entries.filter { entry in
                // Explicitly check if entry has this weather set
                guard let entryWeather = entry.weather else { return false }
                return entryWeather == weather
            }
        }
        
        // Sort
        switch selectedSort {
        case .newest:
            entries = entries.sorted { $0.creationDate > $1.creationDate }
        case .oldest:
            entries = entries.sorted { $0.creationDate < $1.creationDate }
        case .recentlyUnlocked:
            entries = entries.sorted { entry1, entry2 in
                let date1 = entry1.unlockedAt ?? Date.distantPast
                let date2 = entry2.unlockedAt ?? Date.distantPast
                return date1 > date2
            }
        }
        
        return entries
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let text: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 6) {
            Text(text)
                .font(BrandStyle.caption)
                .fontWeight(.medium)
            
            Button {
                onRemove()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 14))
            }
        }
        .foregroundColor(BrandStyle.secondary)
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(BrandStyle.secondary.opacity(0.15))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(BrandStyle.secondary.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    SearchView()
        .environmentObject(StorageService.shared)
}
