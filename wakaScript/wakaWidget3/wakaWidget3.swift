//
//  wakaWidget3.swift
//  wakaWidget3
//
//  Created by Jacob on 6/28/25.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(),
                    dailyTime: "--",
                    hasApiKey: false,
                    apiReply: "N/A",
                    configuration: ConfigurationAppIntent())
    }
    
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        let result = await fetchDailyTime()
        return SimpleEntry(date: Date(),
                           dailyTime: result.dailyTime,
                           hasApiKey: result.hasApiKey,
                           apiReply: result.apiReply,
                           configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let currentDate = Date()
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 30, to: currentDate)!
        let result = await fetchDailyTime()
        let entry = SimpleEntry(date: currentDate,
                                dailyTime: result.dailyTime,
                                hasApiKey: result.hasApiKey,
                                apiReply: result.apiReply,
                                configuration: configuration)
        return Timeline(entries: [entry], policy: .after(refreshDate))
    }
    
    private func fetchDailyTime() async -> (dailyTime: String, hasApiKey: Bool, apiReply: String) {
        guard let userDefaults = UserDefaults(suiteName: "group.hackatime"),
              let savedApiKey = userDefaults.string(forKey: "apiKey"),
              !savedApiKey.isEmpty else {
            return ("--", false, "Missing key")
        }
        let urlString = "https://hackatime.hackclub.com/api/hackatime/v1/users/current/statusbar/today"
        guard let url = URL(string: urlString) else { return ("--", true, "Invalid URL") }
        var request = URLRequest(url: url)
        request.addValue("Bearer \(savedApiKey)", forHTTPHeaderField: "Authorization")
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(HackaTimeResponse.self, from: data)
            let timeText = response.data.grand_total.text
            return (timeText, true, String(data: data, encoding: .utf8) ?? "No raw data")
        } catch {
            return ("--", true, "Error: \(error.localizedDescription)")
        }
    }
}

struct HackaTimeResponse: Codable {
    let data: DataContainer
    struct DataContainer: Codable {
        let grand_total: GrandTotal
    }
    struct GrandTotal: Codable {
        let text: String
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let dailyTime: String
    let hasApiKey: Bool
    let apiReply: String
    let configuration: ConfigurationAppIntent
}

struct wakaWidget3EntryView: View {
    var entry: Provider.Entry

    var body: some View {
        Text(entry.dailyTime)
            .font(.system(size: 40, weight: .bold))
            .minimumScaleFactor(0.5)
            .lineLimit(1)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .multilineTextAlignment(.center)
            .padding()
    }
}

struct wakaWidget3: Widget {
    let kind: String = "wakaWidget3"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind,
                               intent: ConfigurationAppIntent.self,
                               provider: Provider()) { entry in
            wakaWidget3EntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}
