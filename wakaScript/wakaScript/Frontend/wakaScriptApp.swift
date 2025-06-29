//
//  wakaScriptApp.swift
//  wakaScript
//
//  Created by Jacob on 6/18/25.
//

import SwiftUI
import ApplicationServices

@main
struct wakaScriptApp: App {
    @StateObject private var permissions = PermissionChecker()
    @State private var checkedConfig = false
    @State private var hasConfig = false

    var body: some Scene {
        WindowGroup {
            if !permissions.hasAllPermissions {
                AccessibilityWizardView()
                    .environmentObject(permissions)
                    .background(.ultraThinMaterial)
                    .transparentWindow()
                    .hideZoomButton()
            } else {
                Group {
                    if !checkedConfig {
                        Color.clear
                            .onAppear {
                                let path = NSString(string: "~/.wakatime.cfg").expandingTildeInPath
                                hasConfig = FileManager.default.fileExists(atPath: path)
                                checkedConfig = true
                                _ = loadWakaTimeConfig()
                            }
                    } else if hasConfig {
                        SwiftUIView()
                            .background(.ultraThinMaterial)
                            .transparentWindow()
                            .hideZoomButton()
                            .onAppear {
                                                            _ = loadWakaTimeConfig()
                                                        }
                    } else {
                        CfgView {
                            checkedConfig = false
                        }
                        .background(.ultraThinMaterial)
                        .transparentWindow()
                        .hideZoomButton()
                    }
                }
            }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}

class PermissionChecker: ObservableObject {
    @Published var hasAllPermissions: Bool = false
    @Published var hasAccessibility: Bool = false
    @Published var hasAutomation: Bool = false

    init() {
        checkPermissions()
    }

    func checkPermissions() {
        let accessibility = AXIsProcessTrusted()
        hasAccessibility = accessibility

        if accessibility {
            let targetBundleID = "com.apple.systemevents"
            let targetDesc = NSAppleEventDescriptor(bundleIdentifier: targetBundleID)
            let status = AEDeterminePermissionToAutomateTarget(targetDesc.aeDesc, typeWildCard, typeWildCard, true)
            if status == 0 {
                hasAutomation = true
            } else if status == -1743 {
                hasAutomation = false
            } else {
                hasAutomation = false
            }
        } else {
            hasAutomation = false
        }

        hasAllPermissions = hasAccessibility && hasAutomation
    }
}

//button to recall the cfg wizard
