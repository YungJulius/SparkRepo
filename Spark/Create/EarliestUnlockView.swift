//
//  EarliestUnlockView.swift
//  Spark
//
//  Created by Julius Jung on 21.11.2025.
//

import SwiftUI

struct EarliestUnlockView: View {

    @EnvironmentObject var storage: StorageService

    let title: String
    let content: String
    let geofence: Geofence?
    let weather: Weather?
    let emotion: Emotion?

    @State private var useDuration = true      // Time vs Date
    @State private var navigateToFinish = false

    // Duration values
    @State private var years: Int = 0
    @State private var months: Int = 0
    @State private var days: Int = 2      // default 2 days
    @State private var hours: Int = 0

    // Absolute date/time
    @State private var unlockDate: Date = Calendar.current.date(byAdding: .day, value: 2, to: Date())!

    var body: some View {
        VStack(spacing: 24) {

            // ------- Title -------
            Text("Unlock Time")
                .font(BrandStyle.title)

            // ------- Explanation -------
            Text("Choose when the entry can unlock earliest.")
                .font(BrandStyle.body)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            // ------- Mode Switch (Time vs Date) -------
            HStack {
                Button(action: { useDuration = true }) {
                    Text("Time")
                        .font(BrandStyle.button)
                        .foregroundColor(useDuration ? .white : BrandStyle.accent)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 20)
                        .background(
                            useDuration ? BrandStyle.accent : Color.white
                        )
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(BrandStyle.accent, lineWidth: 1)
                        )
                }

                Button(action: { useDuration = false }) {
                    Text("Date")
                        .font(BrandStyle.button)
                        .foregroundColor(!useDuration ? .white : BrandStyle.accent)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 20)
                        .background(
                            !useDuration ? BrandStyle.accent : Color.white
                        )
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(BrandStyle.accent, lineWidth: 1)
                        )
                }
            }

            // ------- Content -------
            if useDuration {
                durationSelector
            } else {
                dateSelector
            }

            Spacer()

            // ------- Finish Button -------
            Button {
                saveEntry()
                navigateToFinish = true
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
        .navigationDestination(isPresented: $navigateToFinish) {
            FinishedView()
        }
    }

    // MARK: - Duration View
    private var durationSelector: some View {
        VStack(spacing: 16) {

            Text("Unlock after:")
                .font(BrandStyle.sectionTitle)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack {
                pickerColumn(label: "Years", range: 0..<10, binding: $years)
                pickerColumn(label: "Months", range: 0..<12, binding: $months)
                pickerColumn(label: "Days", range: 0..<31, binding: $days)
                pickerColumn(label: "Hours", range: 0..<24, binding: $hours)
            }
            .padding()
            .background(BrandStyle.card)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(BrandStyle.accent, lineWidth: 1)
            )
        }
    }

    // MARK: - Date Picker View
    private var dateSelector: some View {
        VStack(spacing: 16) {

            Text("Unlock on:")
                .font(BrandStyle.sectionTitle)
                .frame(maxWidth: .infinity, alignment: .leading)

            DatePicker(
                "",
                selection: $unlockDate,
                in: Date()...Date.distantFuture,
                displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(.graphical)
            .padding()
            .background(BrandStyle.card)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(BrandStyle.accent, lineWidth: 1)
            )
        }
    }

    // MARK: - Picker Column
    private func pickerColumn(label: String, range: Range<Int>, binding: Binding<Int>) -> some View {
        VStack {
            Text(label)
                .font(BrandStyle.caption)
                .foregroundColor(BrandStyle.textSecondary)

            Picker(label, selection: binding) {
                ForEach(range, id: \.self) { v in
                    Text("\(v)")
                        .tag(v)
                }
            }
            .frame(width: 70)
            .clipped()
        }
    }

    // MARK: - Save Entry
    private func saveEntry() {
        let earliestUnlock: Date

        if useDuration {
            let components = DateComponents(
                year: years,
                month: months,
                day: days,
                hour: hours
            )
            earliestUnlock = Calendar.current.date(byAdding: components, to: Date())!
        } else {
            earliestUnlock = unlockDate
        }

        let entry = SparkEntry(
            title: title,
            content: content,
            geofence: geofence,
            weather: weather,
            emotion: emotion,
            creationDate: Date(),
            unlockedAt: nil,
            earliestUnlock: earliestUnlock       // ← NEW FIELD
        )

        storage.add(entry)
    }
}
