//
//  ContentView.swift
//  HackatimeWidget
//
//  Created by Jacob on 6/27/25.
//

import SwiftUI
import WidgetKit

struct ContentView: View {
    @AppStorage("hackatime_api_key", store: UserDefaults(suiteName: "group.hackatime")) private var apiKey: String = ""
    @State private var tempKey: String = ""

    var body: some View {
        VStack(spacing: 20) {
            if apiKey.isEmpty {
                Text("Enter your Hackatime API Key")
                    .font(.headline)
                SecureField("API Key", text: $tempKey)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                Button("Save API Key") {
                    apiKey = tempKey
                    WidgetCenter.shared.reloadAllTimelines()
                }
                .buttonStyle(.borderedProminent)
            } else {
                Text("API Key saved!")
                    .foregroundColor(.green)
                Button("Discard API Key") {
                    apiKey = ""
                    tempKey = ""
                }
                .buttonStyle(.bordered)
            }
            Spacer()
        }
        .padding()
        .onAppear {
            tempKey = apiKey
        }
    }
}

#Preview {
    ContentView()
}
