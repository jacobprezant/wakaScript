//
//  wakatime-project.swift
//  wakaScript
//
//  Created by Jacob on 6/26/25.
//

import Foundation

//function to be called when user sets an alternate project name
func writeWakatimeProjectFile(for filePath: String, projectName: String) throws {
    let fileURL = URL(fileURLWithPath: filePath)
    let directoryURL = fileURL.deletingLastPathComponent()
    let wakatimeProjectURL = directoryURL.appendingPathComponent(".wakatime-project")
    try projectName.write(to: wakatimeProjectURL, atomically: true, encoding: .utf8)
}
