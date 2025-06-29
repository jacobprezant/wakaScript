//
//  poll.swift
//  wakaScript
//
//  Created by Jacob on 6/18/25.
//
//  Inspired by XRPC
//


import Foundation
import AXSwift
import Cocoa

let scriptEditorBundleId = "com.apple.ScriptEditor2"
var lastEditorFileURL: URL?
var lastEditorFileContents: String?
var lastFileSaveDates: [URL: Date] = [:]

class ScriptEditorPresenceProvider: ObservableObject {    
    
//run scrape on a timer
  var timer: Timer?
  init() {
    self.timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { _ in
      self.scrape()
    })
  }
  
    
//dynamic state of Script Editor
  @Published var presenceState: PresenceState = .editorNoWindowsOpen
  

  func scrape() {

    
    let editorProcess = NSWorkspace.shared.runningApplications.first { $0.bundleIdentifier == scriptEditorBundleId }
    
    guard let scriptEditorApp = Application.allForBundleID(scriptEditorBundleId).first else { self.presenceState = .editorNotRunning; return }
    
    let windows = try? scriptEditorApp.windows()
    
    //grab windows
    let mainWindow: UIElement? = try? scriptEditorApp.attribute(.mainWindow)
    let focusedWindow: UIElement? = try? scriptEditorApp.attribute(.focusedWindow)
    let focusedWindowTitle: String? = try? focusedWindow?.attribute(.title)
    
    // no windows open
    if mainWindow == nil && (windows?.isEmpty ?? false) {
      self.presenceState = .editorNoWindowsOpen
    }
    
    //check if on the file picker screen
    if focusedWindowTitle?.contains("New Document") ?? false {
      self.presenceState = .isOnWelcome
      return
    }
      
    //extract window title
    let windowTitle: String? = try? mainWindow?.attribute(.title)
    //grab file path and format as url
    let docFilePath: String? = try? mainWindow?.attribute(.document)
    let doc: URL? = docFilePath == nil ? nil : URL(fileURLWithPath: docFilePath!.replacingOccurrences(of: "file://", with: ""))
    
    //date
    let currentSessionDate: Date? = {
      if case .working(let editorState) = presenceState {
        return editorState.sessionDate
      }
      return nil
    }()
    
    //observable state
    let edState = editorState(
      editorFile: doc,
    )
    
    self.presenceState = .working(edState)
      

    //user goes to different file
    func detectFileChange(from currentFile: URL?) {
          // No valid current file nothing
          guard let currentFile else { return }

          // Compare with last file URL
          if currentFile != lastEditorFileURL {
              // File has changed
              print("File changed to: \(currentFile.lastPathComponent)")
              triggerFileChangedEvent(file: currentFile)
          }

          // Update last known file
          lastEditorFileURL = currentFile
      }
    detectFileChange(from: doc)
    
    //file contents modified
      func getFrontDocumentText(from currentFile: URL?) -> String? {
          NSAppleScript(source: """
          tell application "Script Editor"
              if (count of documents) > 0 then return text of front document
          end tell
          """)?.executeAndReturnError(nil).stringValue
      }
      
      
    //compare text
      if let currentText = getFrontDocumentText(from: doc) {
          if currentText != lastEditorFileContents {
              if let doc = doc {
                  triggerFileModifiedEvent(file: doc)
              }
          }
          lastEditorFileContents = currentText
      }
      
      
      if let fileURL = doc {
          if let attrs = try? FileManager.default.attributesOfItem(atPath: fileURL.path),
                 let modDate = attrs[.modificationDate] as? Date {

                  // Check if this file was saved since the last poll
                  if let lastSaved = lastFileSaveDates[fileURL], modDate > lastSaved {
                      triggerFileSavedEvent(file: fileURL)
                  }

                  // overwrite the saved time
                  lastFileSaveDates[fileURL] = modDate
              }
          }
  }
}

//describe the state of the app
enum PresenceState: Equatable {
  case editorNotRunning
  case editorNoWindowsOpen // when there are no windows and is doing nothing
  case working(editorState) // when user is working
  case isOnWelcome
  
  var displayName: String {
    switch self {
    case .editorNotRunning:
      return "Not open"
    case .editorNoWindowsOpen:
      return "No active window"
    case .working:
      return "Working on a project"
    case .isOnWelcome:
      return "In the welcome screen"
    }
  }
}

//describe the info of the current file
struct editorState: Equatable {
  var editorFile: URL?
  var sessionDate: Date?

  var fileName: String? {
    return editorFile?.lastPathComponent.removingPercentEncoding
  }
  
  var fileExtension: String? {
    if let fileName {
      let fx = fileName.split(separator: ".").last
      if let fx {
        return String(fx).lowercased()
      }
    }
    return nil
  }
}
