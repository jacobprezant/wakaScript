//
//  WakaTime-cli.swift
//  wakaScript
//
//  Created by Jacob on 6/19/25.
//

import Foundation
import AXSwift

private var lastSentFile: URL?
private var lastSentTime: Date?

func triggerFileChangedEvent(file: URL) {
    sendHeartbeatIfNeeded(file: file, isWrite: false)
}

func triggerFileModifiedEvent(file: URL) {
    sendHeartbeatIfNeeded(file: file, isWrite: false)
}

func triggerFileSavedEvent(file: URL) {
    sendHeartbeatIfNeeded(file: file, isWrite: true)
}

private func sendHeartbeatIfNeeded(file: URL, isWrite: Bool) {
    let now = Date()
    
    let enoughTimePassed = lastSentTime == nil || now.timeIntervalSince(lastSentTime!) > 120
    let fileChanged = lastSentFile == nil || lastSentFile != file

    guard isWrite || fileChanged || enoughTimePassed else {
        return
    }

    let config = loadWakaTimeConfig()
    guard let apiKey = config.apiKey else {
        return
    }
    
    sendHeartbeat(file: file, isWrite: isWrite, apiKey: apiKey, apiURL: config.apiURL)
    lastSentFile = file
    lastSentTime = now
}

private func sendHeartbeat(file: URL, isWrite: Bool, apiKey: String, apiURL: String?) {
    let wakatimeCLIPath = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".wakatime/wakatime-cli")
        .path

    guard FileManager.default.isExecutableFile(atPath: wakatimeCLIPath) else {
        return
    }
    
    let fileName = file.deletingPathExtension().lastPathComponent

    var arguments = [
        "--entity", file.path,
        "--language", "AppleScript",
        "--project", fileName,
        "--verbose",
        "--plugin", "wakaScript/1.0",
        "--local-file", file.path,
        "--key", apiKey,
        "--category", "coding"
    ]
    
    if let apiURL = apiURL {
        arguments.append(contentsOf: ["--api-url", apiURL])
    }
        
    if isWrite {
        arguments.append("--write")
    }

    let process = Process()
    process.executableURL = URL(fileURLWithPath: wakatimeCLIPath)
    process.arguments = arguments

    try? process.run()
}

//--today will grab analytics note future implementation
//ui option for users to open logs at `~/.wakatime/wakatime.log`

