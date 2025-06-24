//
//  cfggrab.swift
//  wakaScript
//
//  Created by Jacob on 6/23/25.
//

/// Grabs the api_url & api_key values from the cfg's settings section, and return them to be used in WakaTime-cli.swfit as flags
// Structured off of Hackatime V2's (default) API key location
/// UI: Write api_key if empty. Assume default api_url if empty. Block in place to never send heartbeat without api_key
import Foundation

struct WakaTimeConfig {
    let apiURL: String?
    let apiKey: String?
}

func loadWakaTimeConfig() -> WakaTimeConfig {
    let configPath = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".wakatime.cfg").path

    guard let contents = try? String(contentsOfFile: configPath, encoding: .utf8) else {
        return WakaTimeConfig(apiURL: nil, apiKey: nil)
    }

    var inSettings = false
    var apiURL: String?
    var apiKey: String?

    for line in contents.components(separatedBy: .newlines) {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        if trimmed.hasPrefix("[") && trimmed.hasSuffix("]") {
            inSettings = (trimmed == "[settings]")
            continue
        }
        guard inSettings, let eqIdx = trimmed.firstIndex(of: "=") else { continue }
        let key = trimmed[..<eqIdx].trimmingCharacters(in: .whitespaces)
        let value = trimmed[trimmed.index(after: eqIdx)...].trimmingCharacters(in: .whitespaces)
        if key == "api_url" { apiURL = value }
        if key == "api_key" { apiKey = value }
    }

    return WakaTimeConfig(apiURL: apiURL, apiKey: apiKey)
}
