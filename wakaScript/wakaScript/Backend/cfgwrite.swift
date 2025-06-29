//
//  cfgwrite.swift
//  wakaScript
//
//  Created by Jacob on 6/26/25.
//

import Foundation

//writes the cfg file after wizard complete with API URL & key
func writeWakatimeConfig(urlText: String, keyText: String) {
    let config = """
    [settings]
    api_url = \(urlText)
    api_key = \(keyText)
    heartbeat_rate_limit_seconds = 30
    """
    let path = NSString(string: "~/.wakatime.cfg").expandingTildeInPath
    do {
        try config.write(toFile: path, atomically: true, encoding: .utf8)
    } catch {
    }
}

//obfuscates file's full path, so that the API only receives the relative path
func appendHideProjectFolderSetting() {
    let path = NSString(string: "~/.wakatime.cfg").expandingTildeInPath
    let line = "hide_project_folder = true\n"
    if let fileHandle = FileHandle(forWritingAtPath: path) {
        fileHandle.seekToEndOfFile()
        if let data = line.data(using: .utf8) {
            fileHandle.write(data)
        }
        fileHandle.closeFile()
    }
}

//inverse

func appendShowProjectFolderSetting() {
    let path = NSString(string: "~/.wakatime.cfg").expandingTildeInPath
    do {
        let contents = try String(contentsOfFile: path, encoding: .utf8)
        let filtered = contents
            .components(separatedBy: .newlines)
            .filter { !$0.trimmingCharacters(in: .whitespaces).hasPrefix("hide_project_folder = true") }
            .joined(separator: "\n")
        try filtered.write(toFile: path, atomically: true, encoding: .utf8)
    } catch {
    }
}
