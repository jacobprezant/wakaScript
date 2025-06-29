//
//  TimeWidget.swift
//  TimeWidget
//
//  Created by Jacob on 6/27/25.
//


import WidgetKit
import SwiftUI

struct TimeEntry: TimelineEntry {
    let date: Date
    let userTime: String
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> TimeEntry {
        TimeEntry(date: Date(), userTime: "--:--")
    }

    func getSnapshot(in context: Context, completion: @escaping (TimeEntry) -> ()) {
        loadEntry(completion: completion)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TimeEntry>) -> ()) {
        loadEntry { entry in
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: Date())!
            completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
        }
    }

    private func loadEntry(completion: @escaping (TimeEntry) -> Void) {
        let apiKey = UserDefaults(suiteName: "group.hackatime")?.string(forKey: "hackatime_api_key") ?? ""
        guard !apiKey.isEmpty else {
            completion(TimeEntry(date: Date(), userTime: "No API Key"))
            return
        }
        let url = URL(string: "https://hackatime.hackclub.com/api/hackatime/v1/users/current/statusbar/today")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, _, _ in
            let userTime: String
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let dataDict = json["data"] as? [String: Any],
               let grandTotal = dataDict["grand_total"] as? [String: Any],
               let text = grandTotal["text"] as? String {
                userTime = text
            } else {
                userTime = "No/Bad Data"
            }
            completion(TimeEntry(date: Date(), userTime: userTime))
        }.resume()
    }
}

struct TodayStatsWidgetEntryView: View {
    var entry: Provider.Entry
    var body: some View {
        VStack {
            Text(entry.userTime)
                .font(.title)
                .bold()
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

@main
struct TodayStatsWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "TodayStatsWidget", provider: Provider()) { entry in
            TodayStatsWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Hackatime-Time")
        .description("Shows your tracked time for today.")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall, widget: { TodayStatsWidget() }, timeline: {
    [TimeEntry(date: .now, userTime: "2h 34m")]
} as @MainActor () async -> [TimeEntry])
